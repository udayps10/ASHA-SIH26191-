package com.aasha.web.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.*;

/**
 * Pulls per-year flood history for a locality from ISRO Bhuvan's public WMS
 * (flood.exe: as_fld_1998..2010 / br_fld_1998..2010) by sampling a 1x1 pixel
 * at the location for each year. Flood pixels are magenta (ff00ff).
 * Results are cached in memory and persisted to data/flood_history.json
 * so history stays available offline after first fetch.
 */
@Service
public class FloodHistoryService {
    private static final Logger log = LoggerFactory.getLogger(FloodHistoryService.class);
    private static final String WMS = "https://bhuvan-ras2.nrsc.gov.in/cgi-bin/flood.exe";
    private static final int[] YEARS = {1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010};
    private static final Path CACHE_FILE = Path.of("data", "flood_history.json");

    public record FloodHistory(Double latitude, Double longitude, String state, String coverage,
                               List<Integer> floodYears, int floodCount, int yearsCovered,
                               double historyIndex, String source, String note) {}

    private final RestTemplate client;
    private final Map<String, FloodHistory> cache = new ConcurrentHashMap<>();
    private final ExecutorService pool = Executors.newFixedThreadPool(2, r -> {
        Thread t = new Thread(r, "flood-wms");
        t.setDaemon(true);
        return t;
    });

    public FloodHistoryService() {
        var factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(8000);
        factory.setReadTimeout(12000);
        client = new RestTemplate(factory);
        loadCache();
    }

    public FloodHistory at(double lat, double lon) {
        if (!Double.isFinite(lat) || !Double.isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180)
            throw new IllegalArgumentException("Invalid coordinates");
        String state = stateFor(lat, lon);
        String key = String.format(Locale.ROOT, "%.2f,%.2f", lat, lon);
        if ("NONE".equals(state)) return new FloodHistory(lat, lon, "NONE", "NONE",
                List.of(), 0, 0, 0, "ISRO Bhuvan WMS", "Outside Assam/Bihar flood layer coverage");
        var hit = cache.get(key);
        if (hit != null) return hit;
        FloodHistory result = fetch(lat, lon, state, key);
        if (!"UNAVAILABLE".equals(result.coverage())) {
            cache.put(key, result);
            saveCache();
        }
        return result;
    }

    private FloodHistory fetch(double lat, double lon, String state, String key) {
        String prefix = "AS".equalsIgnoreCase(state) ? "as" : "br";
        List<Future<int[]>> futures = new ArrayList<>();
        for (int year : YEARS) {
            futures.add(pool.submit(() -> samplePixel(prefix + "_fld_" + year, lat, lon)));
            sleepQuietly(350);
        }
        List<Integer> floodYears = new ArrayList<>();
        int covered = 0;
        int failures = 0;
        boolean[] done = new boolean[YEARS.length];
        int[][] pixels = new int[YEARS.length][];
        for (int i = 0; i < futures.size(); i++) {
            try {
                int[] px = futures.get(i).get(30, TimeUnit.SECONDS);
                if (px == null) { failures++; continue; }
                done[i] = true;
                pixels[i] = px;
                covered++;
            } catch (Exception e) {
                failures++;
                log.warn("[FLOOD-HISTORY] year {} unavailable: {}", YEARS[i], e.toString());
            }
        }
        if (failures < YEARS.length) {
            for (int i = 0; i < YEARS.length; i++) {
                if (done[i]) continue;
                sleepQuietly(600);
                try {
                    int[] px = samplePixel(prefix + "_fld_" + YEARS[i], lat, lon);
                    if (px == null) continue;
                    done[i] = true;
                    pixels[i] = px;
                    covered++;
                } catch (Exception e) {
                    log.warn("[FLOOD-HISTORY] retry year {} failed: {}", YEARS[i], e.toString());
                }
            }
        }
        for (int i = 0; i < YEARS.length; i++) {
            if (done[i] && isFloodPixel(pixels[i][0], pixels[i][1], pixels[i][2])) floodYears.add(YEARS[i]);
        }
        double index = covered == 0 ? 0 : Math.round((floodYears.size() * 10.0 / covered) * 10) / 10.0;
        String coverage = covered == YEARS.length ? "FULL" : covered == 0 ? "UNAVAILABLE" : "PARTIAL";
        String note = "BR".equalsIgnoreCase(state) && floodYears.isEmpty() && covered > 0
                ? "Bhuvan Bihar layers returned blank to machine queries (known server issue); history may be under-reported"
                : covered == 0 ? "ISRO WMS unreachable or throttled; try again later" : "";
        log.info("[FLOOD-HISTORY] {} {} : {}/{} years covered, {} flood hits, index={}",
                state, key, covered, YEARS.length, floodYears.size(), index);
        return new FloodHistory(lat, lon, state, coverage, List.copyOf(floodYears),
                floodYears.size(), covered, index,
                "ISRO Bhuvan WMS flood.exe (annual flood maps 1998-2010)", note);
    }

    private static void sleepQuietly(long ms) {
        try { Thread.sleep(ms); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }

    /** Returns {r,g,b,a} of center pixel, or null for throttle/error/undecodable responses. */
    private int[] samplePixel(String layer, double lat, double lon) {
        String url = WMS + "?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap"
                + "&LAYERS=" + layer + "&STYLES=&SRS=EPSG:4326"
                + "&BBOX=" + (lon - 0.005) + "," + (lat - 0.005) + "," + (lon + 0.005) + "," + (lat + 0.005)
                + "&WIDTH=5&HEIGHT=5&FORMAT=image/png&TRANSPARENT=TRUE";
        byte[] body = client.getForObject(url, byte[].class);
        if (body == null || body.length == 0) return null;
        try {
            BufferedImage img = ImageIO.read(new java.io.ByteArrayInputStream(body));
            if (img == null) return null;
            int argb = img.getRGB(2, 2);
            int a = (argb >>> 24) & 0xFF, r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF;
            log.debug("[WMS-PIXEL] {} bytes={} a={} r={} g={} b={}", layer, body.length, a, r, g, b);
            if (a == 255 && r > 240 && g > 240 && b > 240) return null;
            return new int[]{r, g, b, a};
        } catch (java.io.IOException e) {
            return null;
        }
    }

    static boolean isFloodPixel(int r, int g, int b) {
        boolean cyan = g > 180 && b > 180 && r < 100;
        boolean magenta = r > 180 && b > 180 && g < 100;
        return cyan || magenta;
    }

    private static String stateFor(double lat, double lon) {
        if (lon >= 89.0 && lon <= 97.0 && lat >= 24.0 && lat <= 28.5) return "AS";
        if (lon >= 83.3 && lon <= 88.3 && lat >= 24.2 && lat <= 27.6) return "BR";
        return "NONE";
    }

    public static double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    @SuppressWarnings("unchecked")
    private void loadCache() {
        try {
            if (!Files.exists(CACHE_FILE)) return;
            String json = Files.readString(CACHE_FILE);
            if (json.isBlank()) return;
            var mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            List<Map<String, Object>> rows = mapper.readValue(json, List.class);
            for (var row : rows) {
                var h = new FloodHistory(
                        ((Number) row.get("latitude")).doubleValue(),
                        ((Number) row.get("longitude")).doubleValue(),
                        (String) row.get("state"), (String) row.get("coverage"),
                        ((List<Number>) row.get("floodYears")).stream().map(Number::intValue).toList(),
                        ((Number) row.get("floodCount")).intValue(),
                        ((Number) row.get("yearsCovered")).intValue(),
                        ((Number) row.get("historyIndex")).doubleValue(),
                        (String) row.get("source"),
                        row.get("note") == null ? "" : (String) row.get("note"));
                cache.put(String.format(Locale.ROOT, "%.2f,%.2f", h.latitude(), h.longitude()), h);
            }
            log.info("[FLOOD-HISTORY] loaded {} cached localities", cache.size());
        } catch (Exception e) {
            log.warn("[FLOOD-HISTORY] cache load failed: {}", e.toString());
        }
    }

    private synchronized void saveCache() {
        try {
            Files.createDirectories(CACHE_FILE.getParent());
            var mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.writerWithDefaultPrettyPrinter().writeValue(CACHE_FILE.toFile(), cache.values());
        } catch (Exception e) {
            log.warn("[FLOOD-HISTORY] cache save failed: {}", e.toString());
        }
    }
}

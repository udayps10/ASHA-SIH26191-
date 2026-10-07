package com.aasha.web.service;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.stereotype.Service;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;
import java.time.*;
import java.util.*;

/** Open-Meteo model estimates and Copernicus elevation, never invented defaults. */
@Service
public class LiveHazardService {
    public record LiveRisk(Integer riskScore, String zone, List<HazardRiskService.FactorAttribution> factors,
        String explanationSummary, String dataSource, boolean partialData, Double rainfallMmhr,
        Double elevationM, String observedAt, String fetchedAt, List<String> missingFactors) {}
    private record Cached(LiveRisk value, Instant expires) {}
    private final RestTemplate client;
    private final Clock clock;
    private final Map<String, Cached> cache = Collections.synchronizedMap(new LinkedHashMap<>(256, .75f, true) {
        protected boolean removeEldestEntry(Map.Entry<String, Cached> e) { return size() > 256; }
    });
    public LiveHazardService() {
        var factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(3000);
        factory.setReadTimeout(3000);
        client = new RestTemplate(factory);
        clock = Clock.systemUTC();
    }
    LiveHazardService(RestTemplate client, Clock clock) { this.client = client; this.clock = clock; }

    public LiveRisk at(double lat, double lon) {
        if (!Double.isFinite(lat) || !Double.isFinite(lon) || Math.abs(lat) > 90 || Math.abs(lon) > 180)
            throw new IllegalArgumentException("Invalid coordinates");
        // About 100m cells; bounded cache avoids repeated requests on refresh.
        String key = String.format(Locale.ROOT, "%.3f,%.3f", lat, lon);
        var cached = cache.get(key);
        if (cached != null && cached.expires().isAfter(clock.instant())) return cached.value();
        String query = String.format(Locale.ROOT, "latitude=%.3f&longitude=%.3f", lat, lon);
        Double rain = null, elevation = null;
        String observed = null;
        try {
            var weather = client.getForObject("https://api.open-meteo.com/v1/forecast?" + query
                + "&current=rain,showers&timezone=GMT&forecast_days=1", JsonNode.class);
            var current = weather.path("current");
            double interval = number(current.path("interval"), 1, 3600);
            double largeScale = number(current.path("rain"), 0, 2000);
            double showers = number(current.path("showers"), 0, 2000);
            if (!"mm".equals(weather.path("current_units").path("rain").asText())
                || !"mm".equals(weather.path("current_units").path("showers").asText()))
                throw new IllegalArgumentException("Unexpected rainfall units");
            Instant time = LocalDateTime.parse(current.path("time").asText()).toInstant(ZoneOffset.UTC);
            long age = Duration.between(time, clock.instant()).toSeconds();
            if (age < -900 || age > 7200) throw new IllegalArgumentException("Stale weather");
            double rate = (largeScale + showers) * 3600 / interval;
            if (!Double.isFinite(rate) || rate > 2000) throw new IllegalArgumentException("Invalid rain rate");
            rain = rate;
            observed = time.toString();
        } catch (RuntimeException unavailable) { /* Keep rainfall unavailable, not zero. */ }
        try {
            var terrain = client.getForObject("https://api.open-meteo.com/v1/elevation?" + query, JsonNode.class);
            elevation = number(terrain.path("elevation").path(0), -500, 9000);
        } catch (RuntimeException unavailable) { /* Preserve independent weather success. */ }
        var missing = new ArrayList<>(List.of("river proximity", "slope", "drainage", "historical floods", "land use"));
        if (rain == null) missing.add("rainfall");
        if (elevation == null) missing.add("elevation");
        // Elevation above sea level is context only: it does not establish local flood exposure.
        Integer score = rain == null ? null : rain >= 50 ? 35 : rain >= 10 ? 25 : rain > 0 ? 10 : 0;
        String zone = score == null ? "UNKNOWN" : score >= 30 ? "YELLOW" : "GREEN";
        var factors = rain == null ? List.<HazardRiskService.FactorAttribution>of()
            : List.of(new HazardRiskService.FactorAttribution(String.format(Locale.ROOT,
                "Modelled rainfall: %.1f mm/h", rain), score, false));
        var result = new LiveRisk(score, zone, factors,
            "Partial weather estimate; not a flood probability. Elevation is context only. Reported disaster zones still apply.",
            "Open-Meteo weather models / Copernicus DEM GLO-90 (via Open-Meteo)", true,
            rain, elevation, observed, clock.instant().toString(), List.copyOf(missing));
        cache.put(key, new Cached(result, clock.instant().plusSeconds(rain == null || elevation == null ? 30 : 600)));
        return result;
    }
    private static double number(JsonNode node, double min, double max) {
        if (!node.isNumber() || !Double.isFinite(node.doubleValue()) || node.doubleValue() < min || node.doubleValue() > max)
            throw new IllegalArgumentException("Missing or invalid provider value");
        return node.doubleValue();
    }
}

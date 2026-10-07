package com.aasha.web.service;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;

/** Independent rule-based implementation. Contributions are not SHAP values. */
@Service
public class HazardRiskService {
    public static class HazardInput {
        @JsonProperty("rainfall_mmhr") public Double rainfallMmhr;
        @JsonProperty("elevation_m") public Double elevationM;
        @JsonProperty("slope_deg") public Double slopeDeg;
        @JsonProperty("river_distance_m") public Double riverDistanceM;
        @JsonProperty("drainage_capacity") public Double drainageCapacity;
        @JsonProperty("historical_flood_index") public Double historicalFloodIndex;
        @JsonProperty("land_use") public String landUse;
    }
    public record FactorAttribution(String factorName, double contributionScore, boolean isNegative) {}
    public record RiskResult(Integer riskScore, String zone, boolean isRedZone,
        List<FactorAttribution> factors, String explanationSummary, String dataSource,
        boolean partialData) {}

    private static void validate(Double value, String name, double min, double max) {
        if (value != null && (!Double.isFinite(value) || value < min || value > max))
            throw new IllegalArgumentException("Invalid " + name);
    }
    private static void add(List<FactorAttribution> factors, String name, double points) {
        factors.add(new FactorAttribution(name, Math.abs(points), points < 0));
    }
    public RiskResult evaluate(HazardInput f) {
        validate(f.rainfallMmhr, "rainfall", 0, 2000);
        validate(f.elevationM, "elevation", -500, 9000);
        validate(f.slopeDeg, "slope", 0, 90);
        validate(f.riverDistanceM, "river distance", 0, 40000000);
        validate(f.drainageCapacity, "drainage", 0, 10);
        validate(f.historicalFloodIndex, "history", 0, 10);
        var factors = new ArrayList<FactorAttribution>();
        if (f.rainfallMmhr != null) add(factors, f.rainfallMmhr > 120 ? "Heavy rainfall" : f.rainfallMmhr > 80 ? "Moderate rainfall" : "Reported rainfall", f.rainfallMmhr > 120 ? 35 : f.rainfallMmhr > 80 ? 25 : f.rainfallMmhr > 0 ? 10 : 0);
        if (f.riverDistanceM != null) add(factors, "River proximity", f.riverDistanceM <= 150 ? 30 : f.riverDistanceM <= 300 ? 22 : 0);
        if (f.elevationM != null) add(factors, f.elevationM < 430 ? "Low elevation" : "Elevation", f.elevationM < 430 ? 20 : 0);
        if (f.slopeDeg != null) add(factors, "Flat terrain", f.slopeDeg < 5 ? 10 : f.slopeDeg < 15 ? 5 : 0);
        if (f.drainageCapacity != null) add(factors, "Limited drainage", f.drainageCapacity <= 3 ? 15 : f.drainageCapacity <= 5 ? 5 : 0);
        if (f.historicalFloodIndex != null) add(factors, "Historical flood risk", f.historicalFloodIndex * 1.5);
        if (f.landUse != null) {
            String land = f.landUse.toLowerCase(java.util.Locale.ROOT).trim();
            boolean vegetation = land.equals("forest") || land.equals("green");
            add(factors, vegetation ? "Vegetation cover" : "Land use", land.equals("urban") || land.equals("concrete") ? 8 : vegetation ? -5 : 0);
        }
        if (factors.isEmpty()) return new RiskResult(null, "UNKNOWN", false, List.of(),
            "Hazard measurements unavailable", "supplied measurements", true);
        int score = (int)Math.round(Math.max(0, Math.min(100, factors.stream()
            .mapToDouble(v -> v.isNegative() ? -v.contributionScore() : v.contributionScore()).sum())));
        String zone = score >= 80 ? "RED" : score >= 50 ? "ORANGE" : score >= 30 ? "YELLOW" : "GREEN";
        boolean partial = factors.size() < 7;
        var contributing = factors.stream().filter(v -> v.contributionScore() > 0).toList();
        String summary = String.join("; ", contributing.stream().map(FactorAttribution::factorName).toList());
        return new RiskResult(score, zone, score >= 80, contributing,
            (partial ? "Partial data estimate. " : "") + summary, "supplied measurements", partial);
    }
}

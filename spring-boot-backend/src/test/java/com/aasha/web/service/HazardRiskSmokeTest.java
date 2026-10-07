package com.aasha.web.service;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.aasha.web.controller.HazardController;
public class HazardRiskSmokeTest {
    public static void main(String[] args) throws Exception {
        var mapper = new ObjectMapper();
        var service = new HazardRiskService();
        var input = mapper.readValue("{\"rainfall_mmhr\":150,\"river_distance_m\":100,\"elevation_m\":410}", HazardRiskService.HazardInput.class);
        var result = service.evaluate(input);
        if (result.riskScore() != 85 || !result.isRedZone() || result.factors().size() != 3) throw new AssertionError(result);
        if (!mapper.writeValueAsString(result).contains("Heavy rainfall")) throw new AssertionError();
        if (service.evaluate(new HazardRiskService.HazardInput()).riskScore() != null) throw new AssertionError();
        input.rainfallMmhr = -1.0;
        try { service.evaluate(input); throw new AssertionError(); } catch (IllegalArgumentException expected) { }
        System.out.println("PASS: JSON binding, RED=85, explanations, missing/invalid inputs");
    }
}

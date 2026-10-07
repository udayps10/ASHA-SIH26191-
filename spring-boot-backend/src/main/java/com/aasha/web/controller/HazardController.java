package com.aasha.web.controller;

import com.aasha.web.service.FloodHistoryService;
import com.aasha.web.service.HazardRiskService;
import com.aasha.web.service.LiveHazardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/hazard")
public class HazardController {
    private final HazardRiskService service;
    private final LiveHazardService live;
    private final FloodHistoryService flood;
    public HazardController(HazardRiskService service, LiveHazardService live, FloodHistoryService flood) { this.service = service; this.live = live; this.flood = flood; }

    @GetMapping("/history")
    public FloodHistoryService.FloodHistory history(@RequestParam double lat, @RequestParam double lon) {
        return flood.at(lat, lon);
    }

    @PostMapping("/evaluate")
    public HazardRiskService.RiskResult evaluateHazard(@RequestBody HazardRiskService.HazardInput input) {
        return service.evaluate(input);
    }
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> invalidInput(IllegalArgumentException error) {
        return ResponseEntity.badRequest().body(Map.of("error", error.getMessage()));
    }
    @GetMapping("/risk")
    public ResponseEntity<LiveHazardService.LiveRisk> getRisk(@RequestParam double lat, @RequestParam double lon) {
        var result = live.at(lat, lon);
        return ResponseEntity.status(result.rainfallMmhr() == null && result.elevationM() == null ? 503 : 200).body(result);
    }
}

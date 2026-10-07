package com.aasha.web.controller;

import com.aasha.web.entity.SavedSearch;
import com.aasha.web.repository.SavedSearchRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/saved-searches")
public class SavedSearchController {

    private final SavedSearchRepository savedSearchRepo;

    public SavedSearchController(SavedSearchRepository savedSearchRepo) {
        this.savedSearchRepo = savedSearchRepo;
    }

    @PostMapping
    public ResponseEntity<?> saveSearch(
            @RequestParam String searchName,
            @RequestParam String userPhone,
            @RequestParam(required = false) Integer searchAge,
            @RequestParam(required = false) String searchLocation,
            @RequestParam(required = false) String searchAdditionalDetails,
            @RequestParam(defaultValue = "BOTH") String recordType) {
        
        if (searchName == null || searchName.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Name is required"));
        }
        if (userPhone == null || userPhone.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Phone number is required"));
        }

        SavedSearch saved = new SavedSearch();
        saved.setId(UUID.randomUUID().toString());
        saved.setUserPhone(userPhone.trim());
        saved.setSearchName(searchName.trim());
        saved.setSearchAge(searchAge);
        saved.setSearchLocation(searchLocation);
        saved.setSearchAdditionalDetails(searchAdditionalDetails);
        saved.setRecordType(recordType);
        saved.setActive(true);

        savedSearchRepo.save(saved);

        return ResponseEntity.ok(Map.of(
            "id", saved.getId(),
            "message", "Search saved. WhatsApp alerts require an active notification connection; delivery is not confirmed."
        ));
    }

    @GetMapping
    public ResponseEntity<?> listSearches(@RequestParam(required = false) String phone) {
        if (phone != null && !phone.isEmpty()) {
            return ResponseEntity.ok(savedSearchRepo.findMatchingByName(phone));
        }
        return ResponseEntity.ok(savedSearchRepo.findByActiveTrue());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSearch(@PathVariable String id) {
        var search = savedSearchRepo.findById(id);
        if (search.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        search.get().setActive(false);
        savedSearchRepo.save(search.get());
        return ResponseEntity.ok(Map.of("message", "Search deactivated"));
    }
}

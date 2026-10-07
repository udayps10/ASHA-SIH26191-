package com.aasha.web.repository;

import com.aasha.web.entity.SavedSearch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SavedSearchRepository extends JpaRepository<SavedSearch, String> {
    List<SavedSearch> findByActiveTrue();

    @Query("SELECT s FROM SavedSearch s WHERE s.active = true AND " +
           "LOWER(s.searchName) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<SavedSearch> findMatchingByName(@Param("name") String name);
}

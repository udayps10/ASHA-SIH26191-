package com.aasha.web.repository;

import com.aasha.web.entity.Camp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CampRepository extends JpaRepository<Camp, String> {

    List<Camp> findByActiveTrue();

    @Query("SELECT c FROM Camp c WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(c.locationName) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Camp> search(@Param("query") String query);
}

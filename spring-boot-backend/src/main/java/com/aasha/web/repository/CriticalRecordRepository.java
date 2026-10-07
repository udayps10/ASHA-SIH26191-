package com.aasha.web.repository;

import com.aasha.web.entity.CriticalRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CriticalRecordRepository extends JpaRepository<CriticalRecord, String> {

    @Query("SELECT r FROM CriticalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<CriticalRecord> findByNameContaining(@Param("name") String name);

    @Query("SELECT r FROM CriticalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :name, '%')) ORDER BY r.createdAt DESC")
    List<CriticalRecord> findByNameContainingLimited(@Param("name") String name, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM CriticalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :token, '%')) OR LOWER(COALESCE(r.additionalDetails, '')) LIKE LOWER(CONCAT('%', :token, '%')) ORDER BY r.createdAt DESC")
    List<CriticalRecord> findByToken(@Param("token") String token, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM CriticalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :name, '%')) AND r.age = :age")
    List<CriticalRecord> findByNameAndAge(@Param("name") String name, @Param("age") int age);

    List<CriticalRecord> findByCampId(String campId);

    List<CriticalRecord> findTop20ByOrderByCreatedAtDesc();

    @Query("SELECT r FROM CriticalRecord r WHERE r.age BETWEEN :minimumAge AND :maximumAge ORDER BY r.createdAt DESC")
    List<CriticalRecord> findByAgeBetween(@Param("minimumAge") int minimumAge, @Param("maximumAge") int maximumAge, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM CriticalRecord r WHERE LOWER(COALESCE(r.foundLocation, '')) LIKE LOWER(CONCAT('%', :location, '%')) OR LOWER(COALESCE(r.campName, '')) LIKE LOWER(CONCAT('%', :location, '%')) OR LOWER(COALESCE(r.additionalDetails, '')) LIKE LOWER(CONCAT('%', :location, '%')) ORDER BY r.createdAt DESC")
    List<CriticalRecord> findByLocationContaining(@Param("location") String location, org.springframework.data.domain.Pageable pageable);

    long countByStatus(String status);
}

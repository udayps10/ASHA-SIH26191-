package com.aasha.web.repository;

import com.aasha.web.entity.NormalRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NormalRecordRepository extends JpaRepository<NormalRecord, String> {

    @Query("SELECT r FROM NormalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<NormalRecord> findByNameContaining(@Param("name") String name);

    @Query("SELECT r FROM NormalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :name, '%')) ORDER BY r.createdAt DESC")
    List<NormalRecord> findByNameContainingLimited(@Param("name") String name, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM NormalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :token, '%')) OR LOWER(COALESCE(r.additionalDetails, '')) LIKE LOWER(CONCAT('%', :token, '%')) ORDER BY r.createdAt DESC")
    List<NormalRecord> findByToken(@Param("token") String token, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM NormalRecord r WHERE LOWER(r.name) LIKE LOWER(CONCAT('%', :name, '%')) AND r.age = :age")
    List<NormalRecord> findByNameAndAge(@Param("name") String name, @Param("age") int age);

    List<NormalRecord> findByCampId(String campId);

    List<NormalRecord> findTop20ByOrderByCreatedAtDesc();

    @Query("SELECT r FROM NormalRecord r WHERE r.age BETWEEN :minimumAge AND :maximumAge ORDER BY r.createdAt DESC")
    List<NormalRecord> findByAgeBetween(@Param("minimumAge") int minimumAge, @Param("maximumAge") int maximumAge, org.springframework.data.domain.Pageable pageable);

    @Query("SELECT r FROM NormalRecord r WHERE LOWER(COALESCE(r.campName, '')) LIKE LOWER(CONCAT('%', :location, '%')) OR LOWER(COALESCE(r.additionalDetails, '')) LIKE LOWER(CONCAT('%', :location, '%')) ORDER BY r.createdAt DESC")
    List<NormalRecord> findByLocationContaining(@Param("location") String location, org.springframework.data.domain.Pageable pageable);

    long countByStatus(String status);
}

package com.aasha.web.repository;

import com.aasha.web.entity.UserSos;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserSosRepository extends JpaRepository<UserSos, String> {
    List<UserSos> findByUserUidOrderByCreatedAtDesc(String userUid);
    List<UserSos> findByStatusOrderByCreatedAtDesc(String status);
    List<UserSos> findAllByOrderByCreatedAtDesc();
}
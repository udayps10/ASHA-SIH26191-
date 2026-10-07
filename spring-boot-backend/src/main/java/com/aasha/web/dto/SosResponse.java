package com.aasha.web.dto;

import com.aasha.web.entity.UserSos;
import java.time.LocalDateTime;

public record SosResponse(
        String id,
        String userUid,
        String userPhone,
        Double latitude,
        Double longitude,
        Double accuracy,
        String message,
        String status,
        LocalDateTime createdAt,
        LocalDateTime receivedAt
) {
    public static SosResponse from(UserSos sos, String userPhone) {
        return new SosResponse(sos.getId(), sos.getUserUid(), userPhone, sos.getLatitude(),
                sos.getLongitude(), sos.getAccuracy(), sos.getMessage(), sos.getStatus(),
                sos.getCreatedAt(), sos.getReceivedAt());
    }
}

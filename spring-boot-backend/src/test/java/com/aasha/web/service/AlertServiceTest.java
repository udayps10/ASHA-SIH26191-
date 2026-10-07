package com.aasha.web.service;

import com.aasha.web.dto.AlertRequest;
import com.aasha.web.entity.Alert;
import com.aasha.web.repository.AlertRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AlertServiceTest {
    @Mock AlertRepository repository;
    @InjectMocks AlertService service;

    @Test
    void rejectsLatitudeWithoutLongitude() {
        AlertRequest request = validRequest();
        request.setLongitude(null);

        assertThrows(IllegalArgumentException.class, () -> service.create(request));
    }

    @Test
    void rejectsNonPositiveRadius() {
        AlertRequest request = validRequest();
        request.setRadiusKm(0.0);

        assertThrows(IllegalArgumentException.class, () -> service.create(request));
    }

    @Test
    void createsAlertWithoutTrustingClientTimestamp() {
        Alert saved = new Alert();
        saved.setId(1L);
        saved.setTitle("Flood");
        saved.setType("FLOOD");
        saved.setSeverity("SEVERE");
        when(repository.save(any(Alert.class))).thenAnswer(invocation -> {
            Alert value = invocation.getArgument(0);
            value.setId(1L);
            return value;
        });

        var response = service.create(validRequest());

        org.junit.jupiter.api.Assertions.assertEquals(1L, response.id());
    }

    private AlertRequest validRequest() {
        AlertRequest request = new AlertRequest();
        request.setTitle("Flood");
        request.setType("FLOOD");
        request.setSeverity("SEVERE");
        request.setLatitude(19.1);
        request.setLongitude(72.9);
        request.setRadiusKm(10.0);
        return request;
    }
}
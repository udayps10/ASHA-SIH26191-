package com.aasha.web.service;

import com.aasha.web.dto.SosRequest;
import com.aasha.web.entity.UserSos;
import com.aasha.web.repository.UserSosRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserSosServiceTest {
    @Mock UserSosRepository repository;
    @InjectMocks UserSosService service;

    @Test
    void bindsAuthenticatedUserAndSetsReceivedStatus() {
        when(repository.findById("sos-1")).thenReturn(Optional.empty());
        when(repository.save(any(UserSos.class))).thenAnswer(invocation -> invocation.getArgument(0));

        var response = service.create(validRequest(), "authenticated-user");

        var saved = org.mockito.ArgumentCaptor.forClass(UserSos.class);
        org.mockito.Mockito.verify(repository).save(saved.capture());
        assertEquals("authenticated-user", saved.getValue().getUserUid());
        assertEquals("RECEIVED", saved.getValue().getStatus());
        assertEquals("sos-1", response.id());
    }

    @Test
    void returnsExistingRecordForIdempotentRetry() {
        UserSos existing = saved("owner");
        when(repository.findById("sos-1")).thenReturn(Optional.of(existing));

        var response = service.create(validRequest(), "owner");

        assertEquals("sos-1", response.id());
        org.mockito.Mockito.verify(repository, org.mockito.Mockito.never()).save(any());
    }

    @Test
    void rejectsSameIdForAnotherUser() {
        when(repository.findById("sos-1")).thenReturn(Optional.of(saved("other-user")));

        assertThrows(UserSosService.SosConflictException.class,
                () -> service.create(validRequest(), "authenticated-user"));
    }

    @Test
    void rejectsInvalidCoordinatesAndAccuracy() {
        SosRequest request = validRequest();
        request.setLatitude(91.0);
        assertThrows(IllegalArgumentException.class,
                () -> service.create(request, "authenticated-user"));

        SosRequest invalidAccuracy = validRequest();
        invalidAccuracy.setAccuracy(-1.0);
        assertThrows(IllegalArgumentException.class,
                () -> service.create(invalidAccuracy, "authenticated-user"));
    }

    @Test
    void onlyAllowsForwardStatusTransitions() {
        UserSos received = saved("owner");
        when(repository.findById("sos-1")).thenReturn(Optional.of(received));
        var acknowledge = new com.aasha.web.dto.SosStatusRequest();
        acknowledge.setStatus("ACKNOWLEDGED");
        when(repository.save(any(UserSos.class))).thenAnswer(invocation -> invocation.getArgument(0));

        assertEquals("ACKNOWLEDGED", service.updateStatus("sos-1", acknowledge).status());

        var invalid = new com.aasha.web.dto.SosStatusRequest();
        invalid.setStatus("RECEIVED");
        assertThrows(IllegalArgumentException.class,
                () -> service.updateStatus("sos-1", invalid));
    }

    private SosRequest validRequest() {
        SosRequest request = new SosRequest();
        request.setId("sos-1");
        request.setLatitude(19.1);
        request.setLongitude(72.9);
        request.setAccuracy(8.0);
        return request;
    }

    private UserSos saved(String userUid) {
        UserSos sos = new UserSos();
        sos.setId("sos-1");
        sos.setUserUid(userUid);
        sos.setLatitude(19.1);
        sos.setLongitude(72.9);
        sos.setAccuracy(8.0);
        sos.setStatus("RECEIVED");
        return sos;
    }
}

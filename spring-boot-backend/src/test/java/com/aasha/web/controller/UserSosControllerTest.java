package com.aasha.web.controller;

import com.aasha.web.config.JwtAuthFilter;
import com.aasha.web.dto.SosResponse;
import com.aasha.web.repository.UserRepository;
import com.aasha.web.service.UserSosService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(UserSosController.class)
@Import(com.aasha.web.config.SecurityConfig.class)
class UserSosControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UserSosService service;
    @MockBean JwtAuthFilter jwtAuthFilter;
    @MockBean UserRepository userRepository;

    @Test
    void unauthenticatedUserCannotSubmitSos() throws Exception {
        mockMvc.perform(post("/api/sos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validJson()))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(roles = "USER")
    void authenticatedUserCanSubmitSos() throws Exception {
        when(service.create(any(), any())).thenReturn(response());

        mockMvc.perform(post("/api/sos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validJson()))
                .andExpect(status().isCreated());
    }

    @Test
    @WithMockUser(roles = "USER")
    void normalUserCannotListSos() throws Exception {
        mockMvc.perform(get("/api/sos"))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "OFFICIAL")
    void officialCanListSos() throws Exception {
        when(service.all()).thenReturn(List.of(response()));

        mockMvc.perform(get("/api/sos"))
                .andExpect(status().isOk());
    }

            @Test
            @WithMockUser(roles = "OFFICIAL")
            void officialCanReadAndUpdateSos() throws Exception {
            when(service.get("sos-1")).thenReturn(response());
            when(service.updateStatus(any(), any())).thenReturn(response());

            mockMvc.perform(get("/api/sos/sos-1"))
                .andExpect(status().isOk());
            mockMvc.perform(patch("/api/sos/sos-1/status")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"status\":\"ACKNOWLEDGED\"}"))
                .andExpect(status().isOk());
            }

            @Test
            void unauthenticatedUserCannotReadSos() throws Exception {
            mockMvc.perform(get("/api/sos/sos-1"))
                .andExpect(status().isUnauthorized());
            }

            @Test
            @WithMockUser(roles = "USER")
            void normalUserCannotUpdateSosStatus() throws Exception {
            mockMvc.perform(patch("/api/sos/sos-1/status")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"status\":\"ACKNOWLEDGED\"}"))
                .andExpect(status().isForbidden());
            }

    private SosResponse response() {
        return new SosResponse("sos-1", "user-1", null, 19.1, 72.9, 8.0,
                "Need help", "RECEIVED", LocalDateTime.now(), LocalDateTime.now());
    }

    private String validJson() {
        return "{\"id\":\"sos-1\",\"latitude\":19.1,\"longitude\":72.9,\"accuracy\":8}";
    }
}

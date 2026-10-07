package com.aasha.web.service;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestTemplate;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.http.MediaType;
import java.time.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;
import static org.hamcrest.Matchers.containsString;
import static org.junit.jupiter.api.Assertions.*;

class LiveHazardServiceTest {
    private final RestTemplate client = new RestTemplate();
    private final MockRestServiceServer server = MockRestServiceServer.bindTo(client).build();
    private final LiveHazardService service = new LiveHazardService(client,
        Clock.fixed(Instant.parse("2026-09-30T06:00:00Z"), ZoneOffset.UTC));
    private void weather(String data) {
        server.expect(requestTo(containsString("/v1/forecast?"))).andRespond(withSuccess(data, MediaType.APPLICATION_JSON));
    }
    private void elevation() {
        server.expect(requestTo(containsString("/v1/elevation?"))).andRespond(withSuccess("{\"elevation\":[42]}", MediaType.APPLICATION_JSON));
    }
    private String validWeather() {
        return "{\"current_units\":{\"rain\":\"mm\",\"showers\":\"mm\"},\"current\":{\"time\":\"2026-09-30T06:00\",\"interval\":900,\"rain\":2,\"showers\":1}}";
    }
    @Test void convertsIntervalAndCachesWithoutScoringAbsoluteElevation() {
        weather(validWeather()); elevation();
        var result = service.at(26.2, 85);
        assertEquals(12.0, result.rainfallMmhr());
        assertEquals(42.0, result.elevationM());
        assertEquals(25, result.riskScore());
        assertEquals(1, result.factors().size());
        assertTrue(result.partialData());
        assertSame(result, service.at(26.2, 85));
        server.verify();
    }
    @Test void missingRainIsUnknownNotZero() {
        weather("{}"); elevation();
        var result = service.at(0, 0);
        assertNull(result.rainfallMmhr());
        assertNull(result.riskScore());
        assertEquals("UNKNOWN", result.zone());
        assertEquals(42.0, result.elevationM());
    }
    @Test void oldWeatherIsRejected() {
        weather(validWeather().replace("2026-09-30", "2026-09-29")); elevation();
        assertNull(service.at(0, 0).rainfallMmhr());
    }
    @Test void wrongUnitsAreRejected() {
        weather(validWeather().replace("mm", "inch")); elevation();
        assertNull(service.at(0, 0).rainfallMmhr());
    }
    @Test void elevationFailurePreservesRainfall() {
        weather(validWeather());
        server.expect(requestTo(containsString("/v1/elevation?"))).andRespond(withServerError());
        var result = service.at(0, 0);
        assertEquals(12.0, result.rainfallMmhr());
        assertNull(result.elevationM());
    }
    @Test void allProvidersFailWithoutInventingData() {
        server.expect(requestTo(containsString("/v1/forecast?"))).andRespond(withServerError());
        server.expect(requestTo(containsString("/v1/elevation?"))).andRespond(withServerError());
        var result = service.at(0, 0);
        assertNull(result.riskScore());
        assertNull(result.elevationM());
    }
    @Test void rejectsInvalidCoordinatesBeforeNetwork() {
        assertThrows(IllegalArgumentException.class, () -> service.at(Double.NaN, 0));
        assertThrows(IllegalArgumentException.class, () -> service.at(0, 181));
    }
}

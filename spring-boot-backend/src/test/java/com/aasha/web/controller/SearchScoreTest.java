package com.aasha.web.controller;

import com.aasha.web.dto.MatchAiResponse;
import com.aasha.web.entity.NormalRecord;
import com.aasha.web.repository.UserRepository;
import com.aasha.web.service.AiMatchingClient;
import com.aasha.web.service.RecordService;
import org.junit.jupiter.api.Test;
import org.springframework.ui.ExtendedModelMap;
import java.util.List;
import java.util.Map;
import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

class SearchScoreTest {
    @Test void displaysReturnedScoreAndNeverInventsUnavailableScore() {
        var records = mock(RecordService.class);
        var ai = mock(AiMatchingClient.class);
        var record = new NormalRecord(); record.setId("one"); record.setName("Example");
        when(records.searchNormalRecords("Example", 30)).thenReturn(List.of(record));
        var result = new MatchAiResponse.Result(); result.setRecordId("one"); result.setMatchScore(87.4);
        var response = new MatchAiResponse(); response.setResults(List.of(result));
        response.setRequestId("test"); response.setHasMore(true); response.setNextPageToken("3");
        var nextResult = new MatchAiResponse.Result(); nextResult.setRecordId("four"); nextResult.setMatchScore(76.0);
        var next = new MatchAiResponse(); next.setResults(List.of(nextResult));
        when(ai.more(any())).thenReturn(next);
        when(ai.rank(any())).thenReturn(response);
        var controller = new SearchController(records, mock(UserRepository.class), ai);
        var model = new ExtendedModelMap(); controller.searchForm("Example", 30, model);
        assertEquals(87L, ((Map<?,?>) model.get("matchScores")).get("one"));
        assertEquals(76L, ((Map<?,?>) model.get("matchScores")).get("four"));
        when(ai.rank(any())).thenThrow(new AiMatchingClient.MatchingServiceException("offline"));
        model = new ExtendedModelMap(); controller.searchForm("Example", 30, model);
        assertTrue(((Map<?,?>)model.get("matchScores")).isEmpty());
        assertEquals(true, model.get("scoreUnavailable"));
        assertEquals(List.of(record), model.get("results"));
    }
}

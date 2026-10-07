package com.aasha.web.service;
import com.aasha.web.entity.Alert;
import com.aasha.web.service.EvacuationPriorityService.*;
import org.junit.jupiter.api.Test;
import java.time.LocalDateTime;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

class EvacuationPriorityServiceTest {
 final EvacuationPriorityService service=new EvacuationPriorityService();
 final LocalDateTime now=LocalDateTime.of(2026,9,30,12,0);
 Alert flood(){var a=new Alert();a.setId(1L);a.setTitle("Flood");a.setLatitude(0.0);a.setLongitude(0.0);a.setRadiusKm(10.0);a.setActive(true);a.setExpiresAt(now.plusHours(1));return a;}
 Habitation village(String id,double distance,int population,int assistance){return new Habitation(id,id,Math.toDegrees(distance/6371),0.0,population,assistance);}
 @Test void fourHabitationsAlwaysRankByBoundaryDistance(){var input=List.of(village("D",7.8,100000,90000),village("C",4.1,1100,80),village("B",3.4,620,45),village("A",1,850,120));var result=service.calculate(input,List.of(flood()),List.of(),now);assertEquals(List.of("A","B","C","D"),result.priorities().stream().map(p->p.habitation().id()).toList());assertEquals(List.of(1,2,3,4),result.priorities().stream().map(Priority::rank).toList());double[] expected={0,.4,1.1,4.8};for(int i=0;i<4;i++)assertEquals(expected[i],result.priorities().get(i).distanceKm(),.00001);}
 @Test void changedZoneReordersImmediately(){var a=flood();var villages=List.of(village("A",0,1,0),village("B",10,1000,999));assertEquals("A",service.calculate(villages,List.of(a),List.of(),now).priorities().getFirst().habitation().id());a.setLatitude(Math.toDegrees(10.0/6371));assertEquals("B",service.calculate(villages,List.of(a),List.of(),now).priorities().getFirst().habitation().id());}
 @Test void expiredAndInactiveZonesDoNotRank(){var a=flood();a.setExpiresAt(now.minusSeconds(1));var result=service.calculate(List.of(village("A",0,1,0)),List.of(a),List.of(),now);assertTrue(result.zones().isEmpty());assertEquals(0,result.priorities().getFirst().rank());assertNull(result.priorities().getFirst().distanceKm());a.setExpiresAt(null);a.setActive(false);assertTrue(service.calculate(List.of(),List.of(a),List.of(),now).zones().isEmpty());}
 @Test void multipleZonesUseNearestBoundary(){var a=flood();var b=flood();b.setId(2L);b.setLatitude(Math.toDegrees(20.0/6371));var r=service.calculate(List.of(village("A",19,1,0),village("B",8,1,0)),List.of(a,b),List.of(),now);assertEquals("A",r.priorities().getFirst().habitation().id());assertEquals("2",r.priorities().getFirst().zone().id());}
 @Test void exactTiesStayStableRegardlessOfAssistance(){var r=service.calculate(List.of(village("B",1,100,99),village("A",1,1,0)),List.of(flood()),List.of(),now);assertEquals("A",r.priorities().getFirst().habitation().id());}
 @Test void missingRadiusIsExplicitlyEstimated(){var a=flood();a.setRadiusKm(null);var r=service.calculate(List.of(),List.of(a),List.of(),now);assertTrue(r.zones().getFirst().estimated());assertEquals(3,r.zones().getFirst().radiusKm());}
 @Test void missingCoordinatesAreRejected(){assertThrows(IllegalArgumentException.class,()->service.validate(List.of(new Habitation(null,"Village",null,null,10,1))));}
}

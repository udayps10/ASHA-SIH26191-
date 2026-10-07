package com.aasha.web.service;
import com.aasha.web.service.RelocationEngine.*;
import org.junit.jupiter.api.Test;
import java.time.LocalDate;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;
class RelocationEngineTest {
 final RelocationEngine engine=new RelocationEngine();
 Village village(String id,int risk,int people,int assistance){return new Village(id,id,0,0,people,assistance,risk,2,5,"Survey reference",LocalDate.now(),List.of(new Household(id,people,assistance)));}
 Site site(String id,int capacity,boolean verified,boolean accessible){return new Site(id,id,1,1,capacity,0,400,2000,10,capacity,verified,accessible,"Inspection record",LocalDate.now());}
 Input input(List<Village> v,List<Site> s){return new Input("Test",true,4,20,20,v,s,List.of());}
 @Test void respectsLimitsAndKeepsHouseholdsTogether(){var plan=engine.plan(input(List.of(village("v1",85,6,2),village("v2",55,5,0)),List.of(site("s1",8,true,true))),List.of());assertEquals(6,plan.allocated());assertEquals(5,plan.remaining());assertEquals(1,plan.allocations().size());assertEquals(6,plan.sites().getFirst().assigned());}
 @Test void prioritizesImmediateRegardlessOfInputOrder(){var plan=engine.plan(input(List.of(village("low",30,5,0),village("urgent",90,5,2)),List.of(site("s",5,true,true))),List.of());assertEquals("urgent",plan.allocations().getFirst().village());assertEquals("IMMEDIATE",plan.priorities().getFirst().priority());}
 @Test void rejectsUnverifiedAndHazardExposedSites(){var plan=engine.plan(input(List.of(village("v",85,4,0)),List.of(site("unverified",20,false,true),site("hazard",20,true,true))),List.of(new Hazard("Flood",1,1,2)));assertEquals(0,plan.allocated());assertTrue(plan.sites().stream().noneMatch(SiteResult::eligible));}
 @Test void capacityUsesWaterBottleneckAndOccupancy(){var s=new Site("s","s",1,1,100,3,400,200,10,100,true,true,"Survey",LocalDate.now());var plan=engine.plan(input(List.of(village("v",85,4,0)),List.of(s)),List.of());assertEquals(10,plan.sites().getFirst().effectiveCapacity());assertEquals(7,plan.sites().getFirst().available());}
 @Test void assistanceRequiresSuitableAccess(){var plan=engine.plan(input(List.of(village("v",85,4,1)),List.of(site("s",20,true,false))),List.of());assertEquals(4,plan.remaining());}
 @Test void unknownRiskNeedsAssessment(){var v=new Village("v","v",0,0,4,0,null,null,5,"Survey",LocalDate.now(),List.of());var plan=engine.plan(input(List.of(v),List.of(site("s",20,true,true))),List.of());assertEquals("NEEDS_ASSESSMENT",plan.priorities().getFirst().priority());assertEquals(0,plan.allocated());}
 @Test void activeBoundaryRaisesPriority(){var plan=engine.plan(input(List.of(village("v",20,4,0)),List.of(site("s",20,true,true))),List.of(new Hazard("Active flood",0,0,1)));assertEquals("IMMEDIATE",plan.priorities().getFirst().priority());}
 @Test void mismatchAndDuplicateHouseholdsAreRejected(){var v=new Village("v","v",0,0,10,0,80,1,5,"Survey",LocalDate.now(),List.of(new Household("h",4,0)));assertThrows(IllegalArgumentException.class,()->engine.plan(input(List.of(v),List.of()),List.of()));}
 @Test void staleVerificationIsExcluded(){var s=new Site("s","s",1,1,20,0,400,2000,2,20,true,true,"Survey",LocalDate.now().minusDays(8));assertEquals(0,engine.plan(input(List.of(village("v",85,4,0)),List.of(s)),List.of()).allocated());}
 @Test void populationIsConserved(){for(int capacity=0;capacity<30;capacity++){var p=engine.plan(input(List.of(village("a",85,6,1),village("b",55,4,0),village("c",25,3,0)),List.of(site("s",capacity,true,true))),List.of());assertEquals(p.population(),p.allocated()+p.remaining());assertTrue(p.allocated()<=capacity);}}
}

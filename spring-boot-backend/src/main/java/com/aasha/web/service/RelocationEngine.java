package com.aasha.web.service;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.annotation.*;
import java.time.LocalDate;
import java.util.*;

/** Explainable planning rules; all scores and capacity limits require officer validation. */
@Service
public class RelocationEngine {
 public record Household(String id, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int people, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int assistance) {}
 public record Village(String id, String name, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double latitude, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double longitude, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int population,
   @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int assistance, Integer riskScore, Integer pastEvents, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int historyYears, String evidence,
   LocalDate assessedOn, List<Household> households) {}
 public record Site(String id, String name, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double latitude, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double longitude, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int capacity,
   @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int occupancy, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double usableAreaM2, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double waterLitresDaily, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int toilets, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int accessCapacity,
   @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) boolean verified, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) boolean accessible, String evidence, LocalDate verifiedOn) {}
 public record Hazard(String name, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double latitude, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double longitude, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double radiusKm) {}
 public record Input(String title, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) boolean demo, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double areaPerPerson, @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) double waterPerPerson,
   @JsonProperty(required=true) @JsonSetter(nulls=Nulls.FAIL) int peoplePerToilet, List<Village> villages, List<Site> sites, List<Hazard> hazards) {}
 public record Priority(String villageId, String village, String priority, int rank, int riskScore,
   int population, List<String> reasons) {}
 public record SiteResult(String siteId, String site, int effectiveCapacity, int available,
   int assigned, boolean eligible, List<String> reasons) {}
 public record Allocation(String village, String household, String siteId, String site,
   int people, String priority, double distanceKm, String reason) {}
 public record Unallocated(String village, String household, int people, String reason) {}
 public record Plan(List<Priority> priorities, List<SiteResult> sites, List<Allocation> allocations,
   List<Unallocated> unallocated, int population, int allocated, int remaining, List<String> notes) {}
 private void require(boolean test, String message) { if (!test) throw new IllegalArgumentException(message); }
 private void coordinate(double lat,double lon) { require(Double.isFinite(lat)&&Double.isFinite(lon)&&Math.abs(lat)<=90&&Math.abs(lon)<=180,"Invalid coordinates"); }
 private void text(String s,String label) { require(s!=null&&!s.isBlank()&&s.length()<=500,label+" is required (max 500 characters)"); }
 private void positive(double n,String label) { require(Double.isFinite(n)&&n>0&&n<=100000000,label+" must be positive"); }
 public Plan plan(Input in, List<Hazard> activeHazards) {
   require(in!=null,"Planning input required"); text(in.title(),"Title"); require(in.title().length()<=160,"Title too long");
   positive(in.areaPerPerson(),"Area per person"); positive(in.waterPerPerson(),"Water per person"); require(in.peoplePerToilet()>0&&in.peoplePerToilet()<=1000,"Invalid people per toilet");
   require(in.villages()!=null&&!in.villages().isEmpty()&&in.villages().size()<=200,"Provide 1–200 habitations");
   require(in.sites()!=null&&in.sites().size()<=200,"At most 200 sites");
   var hazards=new ArrayList<Hazard>(activeHazards);
   if(in.hazards()!=null) { require(in.hazards().size()<=200,"At most 200 hazard boundaries"); hazards.addAll(in.hazards()); }
   for(var h:hazards) { require(h!=null,"Invalid hazard"); text(h.name(),"Hazard source/name"); coordinate(h.latitude(),h.longitude()); positive(h.radiusKm(),"Hazard radius"); }
   var priorities=new ArrayList<Priority>(); var villages=new HashMap<String,Village>(); var houseIds=new HashSet<String>();
   for(var v:in.villages()) {
     require(v!=null,"Invalid habitation");
     text(v.id(),"Habitation ID");text(v.name(),"Habitation name");coordinate(v.latitude(),v.longitude());
     require(villages.put(v.id(),v)==null,"Duplicate habitation ID");
     require(v.population()>0&&v.population()<=1000000&&v.assistance()>=0&&v.assistance()<=v.population(),"Invalid habitation population/assistance count");
     require(v.riskScore()==null||(v.riskScore()>=0&&v.riskScore()<=100),"Risk must be 0–100 or unknown");
     require(v.pastEvents()==null||(v.pastEvents()>=0&&v.pastEvents()<=10000&&v.historyYears()>0&&v.historyYears()<=100),"Disaster history needs a valid time window");
     text(v.evidence(),"Assessment/history source");
     require(in.demo()||!v.evidence().toUpperCase(Locale.ROOT).contains("FICTIONAL"),"Fictional records must stay in demo mode");
     require(v.assessedOn()!=null&&!v.assessedOn().isAfter(LocalDate.now()),"Assessment date required; cannot be in future");
     if(v.households()!=null&&!v.households().isEmpty()) {
       require(v.households().size()<=2000,"At most 2000 households per habitation");
       int total=0,assistance=0;
       for(var h:v.households()) {require(h!=null,"Invalid household");text(h.id(),"Household ID");require(houseIds.add(v.id()+"/"+h.id()),"Duplicate household ID");require(h.people()>0&&h.people()<=1000&&h.assistance()>=0&&h.assistance()<=h.people(),"Invalid household counts");total+=h.people();assistance+=h.assistance();}
       require(total==v.population()&&assistance==v.assistance(),"Household totals must match habitation population and assistance counts");
     }
     int score=v.riskScore()==null?-1:v.riskScore(); var reasons=new ArrayList<String>();
     reasons.add(score<0?"Risk assessment missing":"Officer-assessed risk: "+score+"/100");
     boolean stale=v.assessedOn().isBefore(LocalDate.now().minusDays(30));
     boolean activeExposure=false;
     for(var h:hazards) if(distance(v.latitude(),v.longitude(),h.latitude(),h.longitude())<=h.radiusKm()) {activeExposure=true;score=Math.max(score,80);reasons.add("Inside reported affected boundary: "+h.name());}
     boolean needs=(score<0||stale)&&!activeExposure;
     String priority=needs?"NEEDS_ASSESSMENT":score>=80?"IMMEDIATE":score>=50||(v.pastEvents()!=null&&v.pastEvents()>=2&&v.assistance()>0)?"SHORT_TERM":"MEDIUM_TERM";
     reasons.add(v.assistance()+" people need evacuation assistance");
     reasons.add(v.pastEvents()==null?"Disaster history unknown":v.pastEvents()+" documented events in "+v.historyYears()+" years");
     if(stale) reasons.add("Assessment older than 30 days; refresh it. Active hazard exposure takes precedence");
     reasons.add("Evidence: "+v.evidence()+" ("+v.assessedOn()+")");
     int rank=needs?0:(priority.equals("IMMEDIATE")?300:priority.equals("SHORT_TERM")?200:100)+Math.min(50,(int)Math.round(50.0*v.assistance()/v.population()))+Math.min(20,v.pastEvents()==null?0:v.pastEvents());
     priorities.add(new Priority(v.id(),v.name(),priority,rank,score,v.population(),reasons));
   }
   priorities.sort(Comparator.comparingInt(Priority::rank).reversed().thenComparing(Priority::villageId));
   var results=new ArrayList<SiteResult>();var siteMap=new HashMap<String,Site>();var free=new HashMap<String,Integer>();
   for(var s:in.sites()) {
     require(s!=null,"Invalid site");
     text(s.id(),"Site ID");text(s.name(),"Site name");coordinate(s.latitude(),s.longitude());require(siteMap.put(s.id(),s)==null,"Duplicate site ID");
     require(s.capacity()>=0&&s.capacity()<=1000000&&s.occupancy()>=0&&s.occupancy()<=1000000&&s.toilets()>=0&&s.toilets()<=100000&&s.accessCapacity()>=0&&s.accessCapacity()<=1000000,"Invalid site counts");
     require(Double.isFinite(s.usableAreaM2())&&s.usableAreaM2()>=0&&s.usableAreaM2()<=100000000&&Double.isFinite(s.waterLitresDaily())&&s.waterLitresDaily()>=0&&s.waterLitresDaily()<=100000000,"Invalid area/water");
     var reasons=new ArrayList<String>();
     if(!s.verified()||s.evidence()==null||s.evidence().isBlank()||s.verifiedOn()==null||s.verifiedOn().isBefore(LocalDate.now().minusDays(7))||s.verifiedOn().isAfter(LocalDate.now())) reasons.add("Needs current officer site verification (within 7 days)");
     for(var h:hazards) if(distance(s.latitude(),s.longitude(),h.latitude(),h.longitude())<=h.radiusKm()) reasons.add("Inside reported affected boundary: "+h.name());
     int cap=(int)Math.min(s.capacity(),Math.min(Math.floor(s.usableAreaM2()/in.areaPerPerson()),Math.min(Math.floor(s.waterLitresDaily()/in.waterPerPerson()),Math.min((long)s.toilets()*in.peoplePerToilet(),s.accessCapacity()))));
     int available=Math.max(0,cap-s.occupancy());
     if(available==0) reasons.add("No available carrying capacity");
     boolean eligible=reasons.isEmpty();
     reasons.add("Capacity is minimum of declared, space, water, sanitation and access limits; existing occupancy deducted");
     free.put(s.id(),eligible?available:0);results.add(new SiteResult(s.id(),s.name(),cap,available,0,eligible,reasons));
   }
   var allocations=new ArrayList<Allocation>();var remaining=new ArrayList<Unallocated>();int population=0,allocated=0;
   for(var p:priorities) {
     var v=villages.get(p.villageId());population+=v.population();
     var households=new ArrayList<>(v.households()==null||v.households().isEmpty()?List.of(new Household(v.id()+"-whole-habitation",v.population(),v.assistance())):v.households());
     households.sort(Comparator.comparingInt(Household::assistance).reversed().thenComparing(Household::id));
     for(var h:households) {
       Site best=null;double nearest=Double.POSITIVE_INFINITY;
       if(!p.priority().equals("NEEDS_ASSESSMENT")) for(var s:in.sites()) {
         if(free.get(s.id())<h.people()||(h.assistance()>0&&!s.accessible()))continue;
         double d=distance(v.latitude(),v.longitude(),s.latitude(),s.longitude());if(d<nearest){best=s;nearest=d;}
       }
       if(best==null) remaining.add(new Unallocated(v.name(),h.id(),h.people(),p.priority().equals("NEEDS_ASSESSMENT")?"Refresh missing/stale risk assessment":"No verified site has enough space for the whole group and required assistance access"));
       else {free.put(best.id(),free.get(best.id())-h.people());allocated+=h.people();allocations.add(new Allocation(v.name(),h.id(),best.id(),best.name(),h.people(),p.priority(),Math.round(nearest*10)/10.0,"Nearest eligible site by straight-line distance; whole group retained"));}
     }
   }
   var finalSites=results.stream().map(s->new SiteResult(s.siteId(),s.site(),s.effectiveCapacity(),s.available(),s.eligible()?s.available()-free.get(s.siteId()):0,s.eligible(),s.reasons())).toList();
   return new Plan(priorities,finalSites,allocations,remaining,population,allocated,population-allocated,List.of(
     in.demo()?"DEMO: fictional scenario, not operational data":"Officer-supplied planning snapshot; verify sources before use",
     "Decision support only. Review does not issue an evacuation order, reserve beds or change actual camp occupancy.",
     "Capacity ratios are scenario assumptions, not certified standards. No route safety is implied. Unverified sites are excluded."));
 }
 public static double distance(double a,double b,double c,double d){double p=Math.PI/180;double x=Math.pow(Math.sin((c-a)*p/2),2)+Math.cos(a*p)*Math.cos(c*p)*Math.pow(Math.sin((d-b)*p/2),2);return 6371*2*Math.asin(Math.sqrt(Math.min(1,x)));}
}

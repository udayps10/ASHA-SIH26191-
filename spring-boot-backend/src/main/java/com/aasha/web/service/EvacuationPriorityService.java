package com.aasha.web.service;

import com.aasha.web.entity.Alert;
import com.aasha.web.entity.Camp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class EvacuationPriorityService {
 public record Habitation(String id,String name,Double latitude,Double longitude,Integer population,Integer assistance) {}
 public record RedZone(String id,String name,double latitude,double longitude,double radiusKm,boolean estimated) {}
 public record Priority(int rank,Habitation habitation,Double distanceKm,RedZone zone,Double priorityScore,Double historyIndex,Integer floodCount,List<Integer> floodYears) {}
 public record CampSpace(String id,String name,double latitude,double longitude,int available,boolean eligible,String reason) {}
 public record Placement(String habitation,String camp,int people) {}
 public record Result(List<RedZone> zones,int unmappedAlerts,List<Priority> priorities,List<CampSpace> camps,List<Placement> placements,int remaining) {}

 private final FloodHistoryService flood;
 public EvacuationPriorityService(){this.flood=null;}
 @Autowired
 public EvacuationPriorityService(FloodHistoryService flood){this.flood=flood;}

 public List<Habitation> validate(List<Habitation> input) {
  if(input==null||input.size()>200) throw new IllegalArgumentException("At most 200 habitations");
  var ids=new HashSet<String>();var output=new ArrayList<Habitation>();
  for(var v:input) {
   if(v==null||v.name()==null||v.name().isBlank()||v.name().length()>160) throw new IllegalArgumentException("Habitation name required (max 160 characters)");
   if(!coordinates(v.latitude(),v.longitude())) throw new IllegalArgumentException("Choose a location for every habitation");
   if(v.population()==null||v.population()<1||v.population()>1000000||v.assistance()==null||v.assistance()<0||v.assistance()>v.population()) throw new IllegalArgumentException("Enter a valid population and assistance count");
   String id=v.id()==null||v.id().isBlank()?UUID.randomUUID().toString():v.id();
   if(id.length()>100||!ids.add(id)) throw new IllegalArgumentException("Invalid habitation ID");
   output.add(new Habitation(id,v.name().trim(),v.latitude(),v.longitude(),v.population(),v.assistance()));
  }
  return output;
 }
 public static boolean coordinates(Double lat,Double lon){return lat!=null&&lon!=null&&Double.isFinite(lat)&&Double.isFinite(lon)&&Math.abs(lat)<=90&&Math.abs(lon)<=180;}

 /** Red-zone proximity points: 100 at boundary, 50 at 10 km, 0 beyond 20 km. */
 static double proximityPoints(Double distanceKm){
  if(distanceKm==null) return 0;
  return Math.max(0,Math.min(100,100-distanceKm*5));
 }

 FloodHistoryService.FloodHistory history(Double lat,Double lon){
  if(flood==null||!coordinates(lat,lon)) return null;
  try{return flood.at(lat,lon);}catch(Exception e){return null;}
 }

 public Result calculate(List<Habitation> input,List<Alert> alerts,List<Camp> camps,LocalDateTime now) {
  var villages=validate(input);var zones=new ArrayList<RedZone>();int unmapped=0;
  for(var a:alerts) {
   if(!a.isActive()||(a.getExpiresAt()!=null&&!a.getExpiresAt().isAfter(now))) continue;
   if(!coordinates(a.getLatitude(),a.getLongitude())||(a.getRadiusKm()!=null&&(!Double.isFinite(a.getRadiusKm())||a.getRadiusKm()<=0))) {unmapped++;continue;}
   // Same geometry as SafetyCalculator.redThreshold and SafetyMapScreen.
   // The existing alert model uses a 10 km estimate when the feed omits radius.
   zones.add(new RedZone(String.valueOf(a.getId()),a.getTitle(),a.getLatitude(),a.getLongitude(),(a.getRadiusKm()==null?10:a.getRadiusKm())*.30,a.getRadiusKm()==null));
  }
  zones.sort(Comparator.comparing(RedZone::id));
  var ranking=new ArrayList<Priority>();
  for(var v:villages) {
   RedZone nearest=null;double distance=Double.POSITIVE_INFINITY;
   for(var z:zones) {double d=Math.max(0,RelocationEngine.distance(v.latitude(),v.longitude(),z.latitude(),z.longitude())-z.radiusKm());if(d<distance){distance=d;nearest=z;}}
   Double dist=nearest==null?null:distance;
   var h=history(v.latitude(),v.longitude());
   Double hIndex=h==null||!"FULL".equals(h.coverage())&&!"PARTIAL".equals(h.coverage())?null:h.historyIndex();
   Double histScore=hIndex==null?null:Math.round(hIndex*10*10)/10.0;
   Double prox=zones.isEmpty()?null:proximityPoints(dist);
   Double score;
   if(histScore!=null&&prox!=null) score=Math.round((.5*prox+.5*histScore)*10)/10.0;
   else if(histScore!=null) score=histScore;
   else if(prox!=null) score=prox;
   else score=null;
   var years=h==null?null:h.floodYears();
   ranking.add(new Priority(0,v,dist,nearest,score,hIndex,h==null?null:h.floodCount(),years));
  }
  if(!zones.isEmpty()){
   ranking.sort(Comparator.comparing((Priority p)->p.priorityScore()==null?-1:p.priorityScore(),Comparator.reverseOrder())
     .thenComparing(Priority::distanceKm,Comparator.nullsLast(Double::compareTo)).thenComparing(p->p.habitation().id()));
  } else ranking.sort(Comparator.comparing(p->p.habitation().id()));
  for(int i=0;i<ranking.size();i++){var p=ranking.get(i);ranking.set(i,new Priority(zones.isEmpty()?0:i+1,p.habitation(),p.distanceKm(),p.zone(),p.priorityScore(),p.historyIndex(),p.floodCount(),p.floodYears()));}
  var spaces=new ArrayList<CampSpace>();
  for(var c:camps) {
   if(!Boolean.TRUE.equals(c.getActive())||!coordinates(c.getLatitude(),c.getLongitude()))continue;
   int available=Math.max(0,(c.getCapacity()==null?0:c.getCapacity())-(c.getOccupancy()==null?0:c.getOccupancy()));
   boolean exposed=zones.stream().anyMatch(z->RelocationEngine.distance(c.getLatitude(),c.getLongitude(),z.latitude(),z.longitude())<=z.radiusKm());
   spaces.add(new CampSpace(c.getId(),c.getName(),c.getLatitude(),c.getLongitude(),available,!exposed&&available>0,exposed?"Inside active red zone":available==0?"No recorded space":"Registered camp; capacity minus occupancy"));
  }
  spaces.sort(Comparator.comparing(CampSpace::id));
  var free=new HashMap<String,Integer>();spaces.forEach(c->free.put(c.id(),c.eligible()?c.available():0));
  var placements=new ArrayList<Placement>();int remaining=0;
  for(var p:ranking){int need=p.habitation().population();
   if(p.zone()!=null){var ordered=new ArrayList<>(spaces);ordered.sort(Comparator.comparingDouble(c->RelocationEngine.distance(p.habitation().latitude(),p.habitation().longitude(),c.latitude(),c.longitude())));
    for(var c:ordered){int n=Math.min(need,free.get(c.id()));if(n>0){placements.add(new Placement(p.habitation().name(),c.name(),n));free.put(c.id(),free.get(c.id())-n);need-=n;}if(need==0)break;}}
   remaining+=need;
  }
  return new Result(zones,unmapped,ranking,spaces,placements,remaining);
 }
}

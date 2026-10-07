package com.aasha.web.controller;
import com.aasha.web.service.RelocationEngine;
import com.aasha.web.service.RelocationEngine.*;
import com.aasha.web.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.DeserializationFeature;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;
import java.time.*;
import java.util.*;

@RestController @RequestMapping("/api/relocation") @PreAuthorize("hasRole('OFFICIAL')")
public class RelocationController {
 private final RelocationEngine engine; private final AlertRepository alerts; private final CampRepository camps;
 private final UserRepository users; private final JdbcTemplate db; private final ObjectMapper json;
 public RelocationController(RelocationEngine engine,AlertRepository alerts,CampRepository camps,UserRepository users,JdbcTemplate db,ObjectMapper json){this.engine=engine;this.alerts=alerts;this.camps=camps;this.users=users;this.db=db;this.json=json;}
 private String owner(Authentication auth){var u=users.findById(auth.getName()).or(()->users.findByEmail(auth.getName())).orElseThrow(()->new ResponseStatusException(HttpStatus.FORBIDDEN));if(!"official".equals(u.getRole())||!Boolean.TRUE.equals(u.getApproved()))throw new ResponseStatusException(HttpStatus.FORBIDDEN);return u.getUid();}
 private List<Hazard> hazards(boolean demo){if(demo)return List.of();return alerts.findByActiveTrueOrderByCreatedAtDesc().stream().filter(a->a.getLatitude()!=null&&a.getLongitude()!=null&&a.getRadiusKm()!=null&&Double.isFinite(a.getRadiusKm())&&a.getRadiusKm()>0&&(a.getExpiresAt()==null||a.getExpiresAt().isAfter(LocalDateTime.now()))).map(a->new Hazard(a.getTitle(),a.getLatitude(),a.getLongitude(),a.getRadiusKm())).toList();}
 @PostMapping("/preview") public Plan preview(@RequestBody JsonNode data,Authentication auth){owner(auth);Input input=decode(data);return engine.plan(input,hazards(input.demo()));}
 private Input decode(JsonNode data){try {if(data==null||!data.isObject())throw new IllegalArgumentException("Planning object required");return json.readerFor(Input.class).without(DeserializationFeature.ACCEPT_FLOAT_AS_INT).with(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES).readValue(data);}catch(java.io.IOException e){throw new IllegalArgumentException("Invalid or missing field: coordinates and resource counts are required; counts must be whole numbers");}}
 @GetMapping("/camps") public Object camps(Authentication auth){owner(auth);return camps.findByActiveTrue();}
 @PostMapping("/plans") public Object save(@RequestBody JsonNode data,Authentication auth)throws Exception {String uid=owner(auth);Input input=decode(data);var result=engine.plan(input,hazards(input.demo()));String id=UUID.randomUUID().toString();db.update("INSERT INTO relocation_plans(id,owner_uid,title,demo,status,input_json,result_json) VALUES(?,?,?,?,?,?,?)",id,uid,input.title(),input.demo(),"DRAFT",json.writeValueAsString(input),json.writeValueAsString(result));return Map.of("id",id,"status","DRAFT","result",result);}
 @GetMapping("/plans") public Object list(Authentication auth){return db.queryForList("SELECT id,title,demo,status,created_at,reviewed_at FROM relocation_plans WHERE owner_uid=? ORDER BY created_at DESC LIMIT 100",owner(auth));}
 @GetMapping("/plans/{id}") public Object get(@PathVariable String id,Authentication auth)throws Exception {var row=row(id,owner(auth));return Map.of("id",id,"status",row.get("status"),"input",json.readTree((String)row.get("input_json")),"result",json.readTree((String)row.get("result_json")),"reviewNote",Objects.toString(row.get("review_note"),""));}
 private Map<String,Object> row(String id,String uid){var rows=db.queryForList("SELECT * FROM relocation_plans WHERE id=? AND owner_uid=?",id,uid);if(rows.isEmpty())throw new ResponseStatusException(HttpStatus.NOT_FOUND);return rows.getFirst();}
 @PostMapping("/plans/{id}/review") public Object review(@PathVariable String id,@RequestBody Map<String,String> request,Authentication auth)throws Exception {
  String uid=owner(auth);var row=row(id,uid);String note=request.get("note");if(note==null||note.isBlank()||note.length()>1000)throw new IllegalArgumentException("Review note required (max 1000 characters)");
  var input=json.readValue((String)row.get("input_json"),Input.class);var latest=engine.plan(input,hazards(input.demo()));
  if(!json.readTree((String)row.get("result_json")).equals(json.valueToTree(latest)))throw new ResponseStatusException(HttpStatus.CONFLICT,"Conditions changed. Preview and save a new draft before review.");
  int changed=db.update("UPDATE relocation_plans SET status='REVIEWED',review_note=?,reviewed_at=CURRENT_TIMESTAMP WHERE id=? AND owner_uid=? AND status='DRAFT'",note,id,uid);
  if(changed!=1)throw new ResponseStatusException(HttpStatus.CONFLICT,"This plan is already reviewed");return Map.of("id",id,"status","REVIEWED");
 }
 @GetMapping("/demo") public Input demo(Authentication auth){owner(auth);var today=LocalDate.now();return new Input("DEMO district relocation exercise",true,4,20,20,
  List.of(new Village("v1","Demo River Village",26.2,85,14,4,85,3,5,"FICTIONAL training survey",today,List.of(new Household("h1",6,2),new Household("h2",4,2),new Household("h3",4,0))),new Village("v2","Demo Hill Village",26.22,85.02,8,2,55,2,5,"FICTIONAL training survey",today,List.of(new Household("h4",4,2),new Household("h5",4,0))),new Village("v3","Demo Outer Village",26.24,85.04,6,0,25,0,5,"FICTIONAL training survey",today,List.of(new Household("h6",6,0)))),
  List.of(new Site("s1","Demo School",26.3,85.1,18,2,100,400,2,18,true,true,"FICTIONAL site inspection",today),new Site("s2","Demo Community Hall",26.32,85.12,8,0,40,160,1,8,true,true,"FICTIONAL site inspection",today)),List.of(new Hazard("Demo flood boundary",26.2,85,2)));}
 public record CsvRequest(String kind,String csv){}
 @PostMapping("/csv") public Object csv(@RequestBody CsvRequest request,Authentication auth){owner(auth);if(!Set.of("villages","households").contains(request.kind()))throw new IllegalArgumentException("Choose villages or households CSV");if(request.csv()==null||request.csv().length()>250000)throw new IllegalArgumentException("CSV must be under 250 KB");var rows=parseCsv(request.csv());if(rows.size()<2||rows.size()>2001)throw new IllegalArgumentException("CSV needs a header and 1–2000 rows");var header=rows.getFirst();
  var expected="households".equals(request.kind())?List.of("villageId","id","people","assistance"):List.of("id","name","latitude","longitude","population","assistance","riskScore","pastEvents","historyYears","evidence","assessedOn");
  if(!header.equals(expected))throw new IllegalArgumentException("Expected columns: "+String.join(",",expected));
  var output=new ArrayList<Map<String,Object>>();var ids=new HashSet<String>();for(int i=1;i<rows.size();i++){var row=rows.get(i);if(row.size()!=header.size())throw new IllegalArgumentException("Wrong column count on CSV row "+(i+1));var value=new LinkedHashMap<String,Object>();for(int j=0;j<header.size();j++){String key=header.get(j),v=row.get(j).trim();if(Set.of("latitude","longitude").contains(key))value.put(key,Double.valueOf(v));else if(Set.of("population","assistance","riskScore","pastEvents","historyYears","people").contains(key))value.put(key,v.isEmpty()?null:Integer.valueOf(v));else value.put(key,v);}String key=Objects.toString(value.get("villageId"),"")+"/"+value.get("id");if(!ids.add(key))throw new IllegalArgumentException("Duplicate CSV ID: "+key);output.add(value);}return output;
 }
 static List<List<String>> parseCsv(String text){var rows=new ArrayList<List<String>>();var row=new ArrayList<String>();var cell=new StringBuilder();boolean quoted=false;for(int i=0;i<text.length();i++){char c=text.charAt(i);if(c=='"'){if(quoted&&i+1<text.length()&&text.charAt(i+1)=='"'){cell.append('"');i++;}else quoted=!quoted;}else if(c==','&&!quoted){row.add(cell.toString());cell.setLength(0);}else if((c=='\n'||c=='\r')&&!quoted){if(c=='\r'&&i+1<text.length()&&text.charAt(i+1)=='\n')i++;row.add(cell.toString());if(row.stream().anyMatch(s->!s.isBlank()))rows.add(row);row=new ArrayList<>();cell.setLength(0);}else cell.append(c);}if(quoted)throw new IllegalArgumentException("Unclosed CSV quote");row.add(cell.toString());if(row.stream().anyMatch(s->!s.isBlank()))rows.add(row);if(!rows.isEmpty()&&!rows.getFirst().isEmpty())rows.getFirst().set(0,rows.getFirst().getFirst().replace("\uFEFF",""));return rows;}
 @ExceptionHandler(IllegalArgumentException.class) public ResponseEntity<?> invalid(IllegalArgumentException e){return ResponseEntity.badRequest().body(Map.of("error",e.getMessage()==null?"Invalid planning data":e.getMessage()));}
}

package com.aasha.web.controller;
import com.aasha.web.service.EvacuationPriorityService;
import com.aasha.web.service.EvacuationPriorityService.*;
import com.aasha.web.repository.*;
import com.fasterxml.jackson.databind.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.*;
import java.time.LocalDateTime;
import java.util.*;

@RestController @RequestMapping("/api/relocation/evacuation") @PreAuthorize("hasRole('OFFICIAL')")
public class EvacuationController {
 private final EvacuationPriorityService service;private final AlertRepository alerts;private final CampRepository camps;private final UserRepository users;private final JdbcTemplate db;private final ObjectMapper json;
 public EvacuationController(EvacuationPriorityService service,AlertRepository alerts,CampRepository camps,UserRepository users,JdbcTemplate db,ObjectMapper json){this.service=service;this.alerts=alerts;this.camps=camps;this.users=users;this.db=db;this.json=json;}
 private String owner(Authentication auth){var u=users.findById(auth.getName()).or(()->users.findByEmail(auth.getName())).orElseThrow(()->new ResponseStatusException(HttpStatus.FORBIDDEN));if(!"official".equals(u.getRole())||!Boolean.TRUE.equals(u.getApproved()))throw new ResponseStatusException(HttpStatus.FORBIDDEN);return u.getUid();}
 private List<Habitation> read(String uid)throws Exception {var rows=db.queryForList("SELECT habitations_json FROM evacuation_assessments WHERE owner_uid=?",uid);return rows.isEmpty()?List.of():Arrays.asList(json.readValue((String)rows.getFirst().get("habitations_json"),Habitation[].class));}
 private Result calculate(List<Habitation> v){return service.calculate(v,alerts.findByActiveTrueOrderByCreatedAtDesc(),camps.findByActiveTrue(),LocalDateTime.now());}
 private Object state(String uid,List<Habitation> v)throws Exception {var result=calculate(v);var rows=db.queryForList("SELECT plan_json,reviewed FROM evacuation_assessments WHERE owner_uid=?",uid);boolean generated=!rows.isEmpty()&&rows.getFirst().get("plan_json")!=null&&json.readTree((String)rows.getFirst().get("plan_json")).equals(json.valueToTree(result));return Map.of("habitations",v,"result",result,"generated",generated,"reviewed",generated&&Boolean.TRUE.equals(rows.getFirst().get("reviewed")),"checkedAt",LocalDateTime.now().toString());}
 @GetMapping public Object get(Authentication auth)throws Exception {String uid=owner(auth);return state(uid,read(uid));}
 @PostMapping public Object save(@RequestBody JsonNode data,Authentication auth)throws Exception {String uid=owner(auth);List<Habitation> v;try{v=service.validate(Arrays.asList(json.readerFor(Habitation[].class).without(DeserializationFeature.ACCEPT_FLOAT_AS_INT).readValue(data)));}catch(java.io.IOException e){throw new IllegalArgumentException("Invalid habitation details");}db.update("INSERT INTO evacuation_assessments(owner_uid,habitations_json) VALUES(?,?) ON DUPLICATE KEY UPDATE habitations_json=VALUES(habitations_json),plan_json=NULL,reviewed=FALSE",uid,json.writeValueAsString(v));return state(uid,v);}
 @PostMapping("/generate") public Object generate(Authentication auth)throws Exception {String uid=owner(auth);var v=read(uid);var result=calculate(v);if(v.isEmpty()||result.zones().isEmpty())throw new IllegalArgumentException("A plan needs habitations and mapped active red zones");db.update("UPDATE evacuation_assessments SET plan_json=?,reviewed=FALSE WHERE owner_uid=?",json.writeValueAsString(result),uid);return state(uid,v);}
 @PostMapping("/review") public Object review(Authentication auth)throws Exception {String uid=owner(auth);var v=read(uid);var result=calculate(v);var rows=db.queryForList("SELECT plan_json FROM evacuation_assessments WHERE owner_uid=?",uid);if(rows.isEmpty()||rows.getFirst().get("plan_json")==null||!json.readTree((String)rows.getFirst().get("plan_json")).equals(json.valueToTree(result)))throw new ResponseStatusException(HttpStatus.CONFLICT,"Conditions changed. Generate a new plan before confirming.");db.update("UPDATE evacuation_assessments SET reviewed=TRUE WHERE owner_uid=?",uid);return state(uid,v);}
 @ExceptionHandler(IllegalArgumentException.class) public ResponseEntity<?> invalid(IllegalArgumentException e){return ResponseEntity.badRequest().body(Map.of("error",Objects.toString(e.getMessage(),"Invalid habitation details")));}
}

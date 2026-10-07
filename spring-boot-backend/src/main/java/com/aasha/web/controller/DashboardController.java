package com.aasha.web.controller;

import com.aasha.web.entity.AppUser;
import com.aasha.web.repository.CampRepository;
import com.aasha.web.repository.CriticalRecordRepository;
import com.aasha.web.repository.NormalRecordRepository;
import com.aasha.web.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    private final UserRepository userRepo;
    private final CampRepository campRepo;
    private final NormalRecordRepository normalRepo;
    private final CriticalRecordRepository criticalRepo;

    public DashboardController(UserRepository userRepo, CampRepository campRepo,
                               NormalRecordRepository normalRepo, CriticalRecordRepository criticalRepo) {
        this.userRepo = userRepo;
        this.campRepo = campRepo;
        this.normalRepo = normalRepo;
        this.criticalRepo = criticalRepo;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return "redirect:/login";
        }
        var userOpt = userRepo.findByEmail(auth.getName());
        if (userOpt.isEmpty() || !"official".equalsIgnoreCase(userOpt.get().getRole())) {
            return "redirect:/search";
        }
        AppUser user = userOpt.get();

        model.addAttribute("accountName", user.getName());
        model.addAttribute("officerName", user.getName());
        model.addAttribute("officerContact", user.getPhone() != null ? user.getPhone() : "");
        model.addAttribute("officerUid", user.getUid());
        model.addAttribute("campCount", campRepo.count());
        model.addAttribute("normalCount", normalRepo.count());
        model.addAttribute("criticalCount", criticalRepo.count());
        model.addAttribute("camps", campRepo.findAll());
        model.addAttribute("normalRecords", normalRepo.findTop20ByOrderByCreatedAtDesc());
        model.addAttribute("criticalRecords", criticalRepo.findTop20ByOrderByCreatedAtDesc());
        return "dashboard";
    }
}

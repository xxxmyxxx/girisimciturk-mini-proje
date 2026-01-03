package com.girisimciturk.miniproje.controller;

import com.girisimciturk.miniproje.dto.ApiResponse;
import com.girisimciturk.miniproje.dto.LiveLessonRequestDTO;
import com.girisimciturk.miniproje.dto.MatchingResponse;
import com.girisimciturk.miniproje.model.Course;
import com.girisimciturk.miniproje.model.LiveLessonRequest;
import com.girisimciturk.miniproje.model.User;
import com.girisimciturk.miniproje.service.CourseService;
import com.girisimciturk.miniproje.service.MatchingService;
import com.girisimciturk.miniproje.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/matching")
@CrossOrigin(origins = "*")
@Tag(name = "Matching", description = "Canlı ders eşleştirme API (Uber mantığı)")
public class MatchingController {

    private final MatchingService matchingService;
    private final UserService userService;
    private final CourseService courseService;

    public MatchingController(MatchingService matchingService, UserService userService, CourseService courseService) {
        this.matchingService = matchingService;
        this.userService = userService;
        this.courseService = courseService;
    }

    /**
     * Canlı ders talebi oluştur ve otomatik eğitmen ataması yap
     */
    @Operation(
        summary = "Canlı ders talebi oluştur",
        description = "Akıllı algoritma ile en uygun eğitmeni otomatik atar"
    )
    @PostMapping("/request-lesson")
    public ResponseEntity<ApiResponse<MatchingResponse>> requestLesson(@RequestBody LiveLessonRequestDTO requestDTO) {

        Optional<User> userOpt = userService.getUserById(requestDTO.getUserId());
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Kullanıcı bulunamadı"));
        }

        Optional<Course> courseOpt = courseService.getCourseById(requestDTO.getCourseId());
        if (courseOpt.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Kurs bulunamadı"));
        }

        LiveLessonRequest lessonRequest = matchingService.createLessonRequest(requestDTO);
        String status = lessonRequest.getStatus();

        MatchingResponse matchingResponse = new MatchingResponse(
            !"NO_INSTRUCTOR_FOUND".equals(status) && !"NO_SUITABLE_INSTRUCTOR".equals(status),
            getMessageForStatus(status, requestDTO.getTopic()),
            lessonRequest.getId(),
            lessonRequest.getAssignedInstructorId(),
            lessonRequest.getAssignedInstructorName(),
            lessonRequest.getMatchingScore(),
            lessonRequest.getSuggestedTimeSlots(),
            status
        );

        if ("NO_INSTRUCTOR_FOUND".equals(status)) {
            return ResponseEntity.status(404)
                .body(ApiResponse.error("Bu konu için eğitmen bulunamadı"));
        }

        if ("NO_SUITABLE_INSTRUCTOR".equals(status)) {
            return ResponseEntity.status(503)
                .body(ApiResponse.error("Şu anda uygun eğitmen bulunmuyor"));
        }

        return ResponseEntity.ok(ApiResponse.success("Eşleştirme başarılı", matchingResponse));
    }

    /**
     * Kullanıcının canlı ders taleplerini listele
     */
    @Operation(summary = "Kullanıcının talepleri", description = "Kullanıcının tüm canlı ders taleplerini döner")
    @GetMapping("/my-requests/{userId}")
    public ResponseEntity<ApiResponse<List<LiveLessonRequest>>> getMyRequests(@PathVariable Long userId) {
        List<LiveLessonRequest> requests = matchingService.getUserRequests(userId);
        return ResponseEntity.ok(ApiResponse.success("Talepler başarıyla getirildi", requests));
    }

    /**
     * Eğitmenin aldığı canlı ders taleplerini listele
     */
    @Operation(summary = "Eğitmenin talepleri", description = "Eğitmene atanan tüm canlı ders taleplerini döner")
    @GetMapping("/instructor-requests/{instructorId}")
    public ResponseEntity<ApiResponse<List<LiveLessonRequest>>> getInstructorRequests(@PathVariable Long instructorId) {
        List<LiveLessonRequest> requests = matchingService.getInstructorRequests(instructorId);
        return ResponseEntity.ok(ApiResponse.success("Talepler başarıyla getirildi", requests));
    }

    /**
     * Eğitmen dashboard verilerini getir
     */
    @Operation(summary = "Eğitmen dashboard", description = "Eğitmenin tüm talepler ve istatistiklerini döner")
    @GetMapping("/instructor-dashboard/{instructorId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getInstructorDashboard(@PathVariable Long instructorId) {
        Optional<User> userOpt = userService.getUserById(instructorId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest()
                .body(ApiResponse.error("Kullanıcı bulunamadı"));
        }

        List<LiveLessonRequest> lessonRequests = matchingService.getInstructorRequests(instructorId);
        List<Course> instructorCourses = courseService.getCoursesByInstructorId(instructorId);

        Map<String, Object> dashboard = new HashMap<>();
        dashboard.put("lessonRequests", lessonRequests);
        dashboard.put("courses", instructorCourses);
        dashboard.put("totalRequests", lessonRequests.size());
        dashboard.put("pendingRequests", lessonRequests.stream()
                .filter(r -> "PENDING".equals(r.getStatus()) || "MATCHED".equals(r.getStatus()))
                .count());
        dashboard.put("confirmedRequests", lessonRequests.stream()
                .filter(r -> "CONFIRMED".equals(r.getStatus()))
                .count());

        return ResponseEntity.ok(ApiResponse.success("Dashboard verileri başarıyla getirildi", dashboard));
    }

    private String getMessageForStatus(String status, String topic) {
        return switch (status) {
            case "NO_INSTRUCTOR_FOUND" -> "Bu konu için eğitmen bulunamadı: " + topic;
            case "NO_SUITABLE_INSTRUCTOR" -> "Şu anda uygun eğitmen bulunmuyor";
            case "TIME_SUGGESTED" -> "Eğitmen bulundu! Lütfen bir zaman dilimi seçin.";
            case "MATCHED" -> "Eğitmen başarıyla atandı!";
            default -> "Talep oluşturuldu";
        };
    }
}

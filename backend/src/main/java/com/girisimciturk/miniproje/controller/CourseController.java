package com.girisimciturk.miniproje.controller;

import com.girisimciturk.miniproje.dto.ApiResponse;
import com.girisimciturk.miniproje.model.Course;
import com.girisimciturk.miniproje.service.CourseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/courses")
@CrossOrigin(origins = "*")
@Tag(name = "Courses", description = "Kurs yönetimi API")
public class CourseController {

    private final CourseService courseService;

    public CourseController(CourseService courseService) {
        this.courseService = courseService;
    }

    /**
     * Tüm kursları listele
     */
    @Operation(summary = "Tüm kursları listele", description = "Sistemdeki tüm kursların listesini döner")
    @ApiResponses(value = {
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "200",
            description = "Başarılı",
            content = @Content(schema = @Schema(implementation = ApiResponse.class))
        )
    })
    @GetMapping
    public ResponseEntity<ApiResponse<List<Course>>> getAllCourses() {
        List<Course> courses = courseService.getAllCourses();
        return ResponseEntity.ok(ApiResponse.success("Kurslar başarıyla getirildi", courses));
    }

    /**
     * Kullanıcının satın aldığı kursları getir
     */
    @Operation(summary = "Kullanıcının kursları", description = "Kullanıcının satın aldığı kursları döner")
    @GetMapping("/my-courses/{userId}")
    public ResponseEntity<ApiResponse<List<Course>>> getMyCourses(@PathVariable Long userId) {
        List<Course> courses = courseService.getUserCourses(userId);
        return ResponseEntity.ok(ApiResponse.success("Kurslarınız başarıyla getirildi", courses));
    }

    /**
     * Test amaçlı: Manuel kurs atama (Webhook olmadan kullanılır)
     */
    @Operation(summary = "Manuel kurs atama", description = "Test modu için kullanıcıya kurs atar")
    @PostMapping("/assign")
    public ResponseEntity<ApiResponse<String>> assignCourseManually(@RequestBody Map<String, Object> request) {
        try {
            Long userId = Long.valueOf(request.get("userId").toString());
            Long courseId = Long.valueOf(request.get("courseId").toString());

            boolean success = courseService.assignCourseToUser(userId, courseId);

            if (success) {
                return ResponseEntity.ok(ApiResponse.success("Kurs başarıyla atandı", null));
            } else {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Kurs bulunamadı"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(500)
                .body(ApiResponse.error("Hata: " + e.getMessage()));
        }
    }
}

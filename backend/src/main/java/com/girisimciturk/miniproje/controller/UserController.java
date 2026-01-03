package com.girisimciturk.miniproje.controller;

import com.girisimciturk.miniproje.dto.ApiResponse;
import com.girisimciturk.miniproje.model.User;
import com.girisimciturk.miniproje.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@CrossOrigin(origins = "*")
@Tag(name = "Users", description = "Kullanıcı yönetimi API")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Tüm eğitmenleri listele
     */
    @Operation(summary = "Tüm eğitmenler", description = "Sistemdeki tüm eğitmenleri döner")
    @GetMapping("/instructors")
    public ResponseEntity<ApiResponse<List<User>>> getInstructors() {
        List<User> instructors = userService.getInstructors();
        return ResponseEntity.ok(ApiResponse.success("Eğitmenler başarıyla getirildi", instructors));
    }

    /**
     * Müsait eğitmenleri listele
     */
    @Operation(summary = "Müsait eğitmenler", description = "Şu anda müsait olan eğitmenleri döner")
    @GetMapping("/instructors/available")
    public ResponseEntity<ApiResponse<List<User>>> getAvailableInstructors() {
        List<User> instructors = userService.getAvailableInstructors();
        return ResponseEntity.ok(ApiResponse.success("Müsait eğitmenler başarıyla getirildi", instructors));
    }
}

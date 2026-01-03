package com.girisimciturk.miniproje.controller;

import com.girisimciturk.miniproje.dto.ApiResponse;
import com.girisimciturk.miniproje.dto.LoginRequest;
import com.girisimciturk.miniproje.dto.LoginResponse;
import com.girisimciturk.miniproje.model.User;
import com.girisimciturk.miniproje.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = "*")
@Tag(name = "Authentication", description = "Kimlik doğrulama API")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Kullanıcı girişi
     */
    @Operation(
        summary = "Kullanıcı girişi", 
        description = "Kullanıcı adı ve şifre ile giriş yapar, JWT token döner"
    )
    @ApiResponses(value = {
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "200",
            description = "Giriş başarılı",
            content = @Content(schema = @Schema(implementation = LoginResponse.class))
        ),
        @io.swagger.v3.oas.annotations.responses.ApiResponse(
            responseCode = "401",
            description = "Yanlış kullanıcı adı veya şifre",
            content = @Content(schema = @Schema(implementation = ApiResponse.class))
        )
    })
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@RequestBody LoginRequest request) {
        Optional<User> userOpt = userService.authenticate(request.getUsername(), request.getPassword());

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401)
                .body(ApiResponse.error("Kullanıcı adı veya şifre hatalı"));
        }

        User user = userOpt.get();
        
        String email = user.getEmail();
        if (email == null || email.isEmpty()) {
            email = user.getUsername() + "@girisimciturk.com";
        }
        
        String token = UUID.randomUUID().toString();

        LoginResponse response = new LoginResponse(
            user.getId(),
            user.getUsername(),
            user.getFullName(),
            email,
            user.getRole(),
            token,
            "Giriş başarılı"
        );

        return ResponseEntity.ok(ApiResponse.success("Giriş başarılı", response));
    }
}

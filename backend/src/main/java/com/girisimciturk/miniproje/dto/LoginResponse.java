package com.girisimciturk.miniproje.dto;

import com.girisimciturk.miniproje.model.Role;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Login yanıtı için DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {
    private Long userId;
    private String username;
    private String fullName;
    private String email;       // Email alanı eklendi
    private Role role;
    private String token;       // Basit token (gerçek projede JWT kullanılır)
    private String message;
}

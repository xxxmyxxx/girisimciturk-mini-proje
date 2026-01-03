package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Kullanıcı modeli
 * Sisteme giriş yapan kullanıcıları temsil eder
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private Long id;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private Role role;
    
    // Profil fotoğrafı URL'i
    private String photoUrl;
    
    // Kullanıcının satın aldığı kurs ID'leri
    private List<Long> purchasedCourseIds = new ArrayList<>();
    
    // Eğitmen için - verilen kurs ID'leri
    private List<Long> taughtCourseIds = new ArrayList<>();
    
    // Eğitmen için - müsaitlik durumu (canlı ders için)
    private boolean available = true;
    
    // Eğitmen için - detaylı profil bilgileri
    private InstructorProfile instructorProfile;
}

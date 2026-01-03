package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Eğitmen profil modeli
 * Eğitmenin uzmanlık alanları, performans metrikleri ve müsaitlik bilgilerini içerir
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class InstructorProfile {
    private Long instructorId;
    
    // Profil bilgileri
    private String title;                           // Örn: "Senior Flutter Developer"
    private String bio;                             // Kısa biyografi
    private List<String> expertiseAreas = new ArrayList<>();  // Uzmanlık alanları (örn: ["Flutter", "React", "Node.js"])
    
    // Performans metrikleri
    private Double rating = 5.0;                    // Puan (0-5 arası)
    private Integer totalStudents = 0;              // Toplam öğrenci sayısı
    private Integer lessonCountLast30Days = 0;      // Son 30 gündeki ders sayısı
    private String workloadLevel;                   // DÜŞÜK, ORTA, YÜKSEK
    
    // Müsaitlik bilgileri
    private List<TimeSlot> availableTimeSlots = new ArrayList<>();
    private LocalDateTime nearestAvailability;
    
    // Hesaplanmış metrikler
    private Double matchingScore = 0.0;
}

package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Canlı ders talebi modeli
 * Kullanıcının eğitmen eşleştirme talebini temsil eder
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LiveLessonRequest {
    private Long id;
    private Long userId;
    private String userName;
    private Long courseId;                          // Hangi kurs için talep
    private String courseName;
    
    // Öğrenci tercihleri
    private String topic;                           // Konu (örn: "Flutter")
    private String level;                           // Seviye: Başlangıç, Orta, İleri
    private LocalDateTime preferredDateTime;        // Tercih edilen tarih/saat (null olabilir)
    private boolean instructorSuggestsTime;         // Öğretmen zaman önersin mi?
    
    // Eşleştirme bilgileri
    private Long assignedInstructorId;              // Atanan eğitmen ID'si
    private String assignedInstructorName;
    private Double matchingScore;                   // Eşleşme skoru
    
    // Önerilen zaman dilimleri (eğitmen tarafından)
    private List<TimeSlot> suggestedTimeSlots = new ArrayList<>();
    private TimeSlot selectedTimeSlot;              // Öğrenci tarafından seçilen zaman
    
    // Durum bilgileri
    private String status;                          // PENDING, MATCHED, TIME_SUGGESTED, CONFIRMED, COMPLETED, CANCELLED
    private LocalDateTime requestDate;
    private LocalDateTime matchedDate;
    private LocalDateTime confirmedDate;
}

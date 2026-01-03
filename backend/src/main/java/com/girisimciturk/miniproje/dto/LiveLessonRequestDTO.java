package com.girisimciturk.miniproje.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Canlı ders talebi oluşturma için DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LiveLessonRequestDTO {
    private Long userId;
    private Long courseId;
    private String topic;                           // Konu (örn: "Flutter", "Finansal Tablolar")
    private String level;                           // Seviye: Başlangıç, Orta, İleri
    private LocalDateTime preferredDateTime;        // Tercih edilen tarih/saat (opsiyonel)
    private boolean instructorSuggestsTime;         // true ise öğretmen zaman önerir
}

package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Kurs modeli
 * Sistemdeki eğitim içeriklerini temsil eder
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Course {
    private Long id;
    private String title;              // Kurs başlığı
    private String description;        // Kurs açıklaması
    private Long instructorId;         // Eğitmen ID'si
    private String instructorName;     // Eğitmen adı (kolaylık için)
    private Double price;              // Kurs fiyatı (TL)
    private String imageUrl;           // Kurs görseli URL'i
    private Integer duration;          // Kurs süresi (saat)
    private String level;              // Seviye: Başlangıç, Orta, İleri
}

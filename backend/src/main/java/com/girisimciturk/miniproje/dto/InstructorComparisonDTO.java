package com.girisimciturk.miniproje.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Eğitmen karşılaştırma bilgisi için DTO
 * Debug ve analiz amaçlı kullanılır
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class InstructorComparisonDTO {
    private Long instructorId;
    private String instructorName;
    private Double rating;
    private String workloadLevel;
    private Integer availableSlotCount;
    private String nearestAvailability;
    private String slotDistribution;
    private Double finalScore;
    private String reasoning;                       // Skorun nasıl hesaplandığının açıklaması
}

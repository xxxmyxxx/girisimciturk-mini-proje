package com.girisimciturk.miniproje.dto;

import com.girisimciturk.miniproje.model.TimeSlot;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Canlı ders eşleştirme yanıtı için DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MatchingResponse {
    private boolean success;
    private String message;
    private Long requestId;
    private Long instructorId;
    private String instructorName;
    private Double matchingScore;                   // Eşleşme skoru
    private List<TimeSlot> suggestedTimeSlots;      // Önerilen zaman dilimleri
    private String status;                          // MATCHED, TIME_SUGGESTED, vb.
}

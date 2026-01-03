package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Zaman dilimi modeli
 * Eğitmenin müsait olduğu zaman aralıklarını temsil eder
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TimeSlot {
    private Long id;
    private LocalDateTime startTime;    // Başlangıç zamanı
    private LocalDateTime endTime;      // Bitiş zamanı
    private boolean isAvailable;        // Müsait mi?
    private String dayOfWeek;           // Haftanın günü (Pazartesi, Salı, vb.)
}

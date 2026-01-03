package com.girisimciturk.miniproje.dto;

import com.girisimciturk.miniproje.model.OrderStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Sipariş Detay Response DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderDetailsResponse {
    private Long orderId;
    private String orderNumber;
    private OrderStatus status;
    private Double amount;
    private String currency;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    
    // Kurs bilgisi
    private Long courseId;
    private String courseName;
    
    // Ödeme bilgisi
    private String paymentStatus;
    private String transactionId;
}

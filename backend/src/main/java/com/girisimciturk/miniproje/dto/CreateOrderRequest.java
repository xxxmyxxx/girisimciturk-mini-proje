package com.girisimciturk.miniproje.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Sipariş Oluşturma Request DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateOrderRequest {
    private Long userId;
    private Long courseId;
    private String customerEmail;
    private String customerName;
    
    // Frontend'den gelecek - başarı/iptal URL'leri
    private String successUrl;
    private String cancelUrl;
}

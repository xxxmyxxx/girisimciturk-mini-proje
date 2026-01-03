package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Ödeme Modeli (Stripe Entegrasyonlu)
 * 
 * Her ödeme bir siparişe bağlıdır
 * Stripe ile senkronize çalışır
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
    private Long id;
    private Long orderId;              // Sipariş referansı
    private Long userId;
    private Long courseId;
    
    // Tutar bilgileri
    private Double amount;
    private String currency;
    
    // Durum yönetimi
    private PaymentStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Stripe bilgileri
    private String stripePaymentIntentId;    // pi_xxx
    private String stripeSessionId;          // cs_xxx (Checkout Session)
    private String stripeCustomerId;         // cus_xxx
    
    // İşlem bilgileri
    private String transactionId;            // Bizim internal ID'miz
    private String idempotencyKey;           // Tekrar işlemi engellemek için
    
    // Hata yönetimi
    private String errorMessage;
    private String errorCode;
    
    // Metadata
    private String paymentMethod;            // card, wallet, vb.
    private String last4;                    // Kart son 4 hanesi
    private String brand;                    // visa, mastercard
}

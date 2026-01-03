package com.girisimciturk.miniproje.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Sipariş Modeli
 * 
 * Payment'tan bağımsız sipariş yönetimi
 * Her sipariş bir veya daha fazla ödeme denemesine sahip olabilir
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Order {
    private Long id;
    private String orderNumber;        // Benzersiz sipariş numarası (ORD-UUID)
    private Long userId;
    private Long courseId;
    
    // Fiyat bilgileri - sipariş anında sabitlenir
    private Double amount;
    private String currency;           // TRY, USD, EUR
    private Double exchangeRate;       // Sipariş anındaki kur
    
    // Durum yönetimi
    private OrderStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime expiresAt;   // Ödeme süresi (genelde 30dk)
    
    // İlişkiler
    private Long activePaymentId;      // Aktif ödeme ID'si
    
    // Metadata
    private String customerEmail;
    private String customerName;
}

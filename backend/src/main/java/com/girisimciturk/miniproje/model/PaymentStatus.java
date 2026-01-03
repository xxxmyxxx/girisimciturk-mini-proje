package com.girisimciturk.miniproje.model;

/**
 * Ödeme Durumları - Profesyonel State Machine
 * 
 * CREATED: İlk oluşturulma
 * WAITING_FOR_PAYMENT: Ödeme bekleniyor (Stripe checkout açıldı)
 * PAYMENT_INITIATED: Ödeme başlatıldı
 * PAYMENT_PENDING: Banka onayı bekleniyor
 * PAID: Ödeme başarılı ve onaylandı
 * FAILED: Ödeme başarısız
 * EXPIRED: Ödeme süresi doldu
 * REFUNDED: İade edildi
 * CHARGEBACK: Ters ibraz (dispute)
 * CANCELLED: İptal edildi
 */
public enum PaymentStatus {
    CREATED,
    WAITING_FOR_PAYMENT,
    PAYMENT_INITIATED,
    PAYMENT_PENDING,
    PAID,
    FAILED,
    EXPIRED,
    REFUNDED,
    CHARGEBACK,
    CANCELLED
}

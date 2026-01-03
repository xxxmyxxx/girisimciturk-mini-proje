package com.girisimciturk.miniproje.model;

/**
 * Sipariş Durumları
 * 
 * Payment'tan bağımsız sipariş lifecycle'ı
 */
public enum OrderStatus {
    CREATED,           // Sipariş oluşturuldu
    PENDING_PAYMENT,   // Ödeme bekleniyor
    PAID,              // Ödeme tamamlandı
    COMPLETED,         // İşlem tamamlandı (kurs verildi)
    FAILED,            // Başarısız
    CANCELLED,         // İptal edildi
    REFUNDED          // İade edildi
}

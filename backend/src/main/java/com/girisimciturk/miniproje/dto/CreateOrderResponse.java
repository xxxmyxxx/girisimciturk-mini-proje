package com.girisimciturk.miniproje.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Sipariş Response DTO
 * 
 * Stripe Checkout URL'i ile birlikte döner
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateOrderResponse {
    private boolean success;
    private String message;
    private Long orderId;
    private String orderNumber;
    private String stripeCheckoutUrl;    // Kullanıcı buraya yönlendirilecek
    private String stripeSessionId;
}

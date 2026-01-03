package com.girisimciturk.miniproje.config;

import com.stripe.Stripe;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Stripe Konfigürasyonu
 * 
 * Uygulama başlangıcında Stripe API anahtarını ayarlar
 */
@Configuration
public class StripeConfig {

    @Value("${stripe.api.secret-key}")
    private String secretKey;

    /**
     * Stripe SDK'yı başlat
     * Uygulama başlangıcında çalışır
     */
    @PostConstruct
    public void init() {
        Stripe.apiKey = secretKey;
        System.out.println("✅ Stripe SDK initialized successfully");
    }
}

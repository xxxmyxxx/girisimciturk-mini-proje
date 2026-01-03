package com.girisimciturk.miniproje.controller;

import com.girisimciturk.miniproje.model.*;
import com.girisimciturk.miniproje.service.*;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@CrossOrigin(origins = "*")
@Tag(name = "Webhook", description = "Stripe webhook işlemleri (Harici)")
public class StripeWebhookController {

    @Value("${stripe.webhook.secret}")
    private String webhookSecret;

    private final PaymentService paymentService;
    private final OrderService orderService;
    private final CourseService courseService;

    public StripeWebhookController(PaymentService paymentService,
            OrderService orderService,
            CourseService courseService) {
        this.paymentService = paymentService;
        this.orderService = orderService;
        this.courseService = courseService;
    }

    /**
     * Stripe webhook endpoint (Production)
     */
    @Operation(summary = "Stripe webhook", description = "Stripe'dan gelen ödeme bildirimlerini işler")
    @PostMapping("/api/webhook/stripe")
    public ResponseEntity<String> handleStripeWebhookPrimary(
            @RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {
        return handleStripeWebhook(payload, sigHeader);
    }

    /**
     * Stripe CLI webhook endpoint (Development)
     */
    @Operation(summary = "Stripe CLI webhook", description = "Stripe CLI test webhook'u")
    @PostMapping("/stripe/webhook")
    public ResponseEntity<String> handleStripeWebhookAlternative(
            @RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {
        return handleStripeWebhook(payload, sigHeader);
    }

    private ResponseEntity<String> handleStripeWebhook(String payload, String sigHeader) {
        Event event;

        try {
            if (webhookSecret != null && !webhookSecret.isEmpty() &&
                    !webhookSecret.equals("whsec_your_webhook_secret_here")) {
                event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
            } else {
                event = Event.GSON.fromJson(payload, Event.class);
            }
        } catch (SignatureVerificationException e) {
            return ResponseEntity.status(400).body("Invalid signature");
        }

        String eventType = event.getType();

        try {
            switch (eventType) {
                case "checkout.session.completed":
                    handleCheckoutSessionCompleted(event);
                    break;
                case "checkout.session.expired":
                    handleCheckoutSessionExpired(event);
                    break;
                case "payment_intent.succeeded":
                    handlePaymentIntentSucceeded(event);
                    break;
                case "payment_intent.payment_failed":
                    handlePaymentIntentFailed(event);
                    break;
                default:
                    break;
            }
            return ResponseEntity.ok("Event received");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Webhook processing failed");
        }
    }

    /**
     * Ödeme başarılı - Kursu kullanıcıya ata
     */
    private void handleCheckoutSessionCompleted(Event event) {
        try {
            Session session = retrieveSession(event);
            if (session == null) return;

            String paymentStatus = session.getPaymentStatus();
            var metadata = session.getMetadata();
            
            if (metadata == null || metadata.isEmpty()) return;

            Long orderId = Long.parseLong(metadata.get("orderId"));
            Long paymentId = Long.parseLong(metadata.get("paymentId"));
            Long userId = Long.parseLong(metadata.get("userId"));
            Long courseId = Long.parseLong(metadata.get("courseId"));

            Optional<Payment> paymentOpt = paymentService.getPaymentById(paymentId);
            if (paymentOpt.isEmpty() || paymentOpt.get().getStatus() == PaymentStatus.PAID) {
                return;
            }

            if ("paid".equals(paymentStatus)) {
                paymentService.updatePaymentStatus(paymentId, PaymentStatus.PAID, null, null);
                orderService.updateOrderStatus(orderId, OrderStatus.PAID);
                courseService.assignCourseToUser(userId, courseId);
                orderService.updateOrderStatus(orderId, OrderStatus.COMPLETED);
            }
        } catch (Exception e) {
            // Hata loglanmalı
        }
    }

    /**
     * Checkout session süresi doldu
     */
    private void handleCheckoutSessionExpired(Event event) {
        try {
            Session session = (Session) event.getDataObjectDeserializer().getObject().orElseThrow();
            
            String paymentIdStr = session.getMetadata().get("paymentId");
            String orderIdStr = session.getMetadata().get("orderId");

            if (paymentIdStr != null && orderIdStr != null) {
                Long paymentId = Long.parseLong(paymentIdStr);
                Long orderId = Long.parseLong(orderIdStr);

                paymentService.updatePaymentStatus(paymentId, PaymentStatus.EXPIRED, "Session expired", null);
                orderService.updateOrderStatus(orderId, OrderStatus.FAILED);
            }
        } catch (Exception e) {
            // Hata loglanmalı
        }
    }

    private void handlePaymentIntentSucceeded(Event event) {
        // İleride implement edilebilir
    }

    private void handlePaymentIntentFailed(Event event) {
        // İleride implement edilebilir
    }

    /**
     * Session bilgilerini güvenli şekilde al
     */
    private Session retrieveSession(Event event) {
        try {
            var deserializer = event.getDataObjectDeserializer();
            if (deserializer.getObject().isPresent()) {
                return (Session) deserializer.getObject().get();
            }

            String rawJson = event.toJson();
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"id\"\\s*:\\s*\"(cs_[^\"]+)\"");
            java.util.regex.Matcher matcher = pattern.matcher(rawJson);

            if (matcher.find()) {
                String sessionId = matcher.group(1);
                return Session.retrieve(sessionId);
            }
        } catch (Exception e) {
            // Hata loglanmalı
        }
        return null;
    }
}

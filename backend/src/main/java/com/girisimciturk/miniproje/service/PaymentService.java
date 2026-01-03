package com.girisimciturk.miniproje.service;

import com.girisimciturk.miniproje.model.Payment;
import com.girisimciturk.miniproje.model.PaymentStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Ödeme Servisi
 */
@Service
public class PaymentService {

    private final Map<Long, Payment> payments = new ConcurrentHashMap<>();
    private final Map<String, Long> stripePaymentIntentIndex = new ConcurrentHashMap<>();
    private final Map<String, Long> idempotencyIndex = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);
    public Payment createPayment(Long orderId, Long userId, Long courseId,
            Double amount, String currency) {
        Payment payment = new Payment();
        payment.setId(idGenerator.getAndIncrement());
        payment.setOrderId(orderId);
        payment.setUserId(userId);
        payment.setCourseId(courseId);
        payment.setAmount(amount);
        payment.setCurrency(currency != null ? currency : "TRY");

        payment.setStatus(PaymentStatus.CREATED);
        payment.setCreatedAt(LocalDateTime.now());
        payment.setUpdatedAt(LocalDateTime.now());

        payment.setTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase());
        payment.setIdempotencyKey(UUID.randomUUID().toString());

        payments.put(payment.getId(), payment);
        idempotencyIndex.put(payment.getIdempotencyKey(), payment.getId());

        return payment;
    }

    public void updateStripeInfo(Long paymentId, String stripePaymentIntentId,
            String stripeSessionId, String stripeCustomerId) {
        Payment payment = payments.get(paymentId);
        if (payment != null) {
            payment.setStripePaymentIntentId(stripePaymentIntentId);
            payment.setStripeSessionId(stripeSessionId);
            payment.setStripeCustomerId(stripeCustomerId);
            payment.setUpdatedAt(LocalDateTime.now());

            if (stripePaymentIntentId != null) {
                stripePaymentIntentIndex.put(stripePaymentIntentId, paymentId);
            }
        }
    }

    public boolean updatePaymentStatus(Long paymentId, PaymentStatus newStatus,
            String errorMessage, String errorCode) {
        Payment payment = payments.get(paymentId);
        if (payment == null) {
            return false;
        }

        if (payment.getStatus() == newStatus) {
            return true;
        }

        payment.setStatus(newStatus);
        payment.setUpdatedAt(LocalDateTime.now());

        if (errorMessage != null) {
            payment.setErrorMessage(errorMessage);
        }
        if (errorCode != null) {
            payment.setErrorCode(errorCode);
        }

        return true;
    }
    public Optional<Payment> findByStripePaymentIntentId(String paymentIntentId) {
        Long paymentId = stripePaymentIntentIndex.get(paymentIntentId);
        return paymentId != null ? Optional.ofNullable(payments.get(paymentId)) : Optional.empty();
    }

    public Optional<Payment> getPaymentById(Long paymentId) {
        return Optional.ofNullable(payments.get(paymentId));
    }

    public List<Payment> getUserPayments(Long userId) {
        return payments.values().stream()
                .filter(p -> p.getUserId().equals(userId))
                .sorted((p1, p2) -> p2.getCreatedAt().compareTo(p1.getCreatedAt()))
                .toList();
    }

    public List<Payment> getSuccessfulPayments(Long userId) {
        return payments.values().stream()
                .filter(p -> p.getUserId().equals(userId) && p.getStatus() == PaymentStatus.PAID)
                .toList();
    }
    public List<Payment> getPaymentsByOrderId(Long orderId) {
        return payments.values().stream()
                .filter(p -> p.getOrderId().equals(orderId))
                .sorted((p1, p2) -> p2.getCreatedAt().compareTo(p1.getCreatedAt()))
                .toList();
    }
}

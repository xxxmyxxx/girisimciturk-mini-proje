package com.girisimciturk.miniproje.service;

import com.girisimciturk.miniproje.model.Order;
import com.girisimciturk.miniproje.model.Payment;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class StripeService {

    @Value("${app.frontend.url}")
    private String frontendUrl;

    public Session createCheckoutSession(Order order, Payment payment,
            String successUrl, String cancelUrl) throws StripeException {

        Long amountInCents = (long) (order.getAmount() * 100);

        String finalSuccessUrl;
        String finalCancelUrl;
        
        if (successUrl != null && !successUrl.trim().isEmpty()) {
            finalSuccessUrl = successUrl;
        } else {
            finalSuccessUrl = frontendUrl + "/payment-success?session_id={CHECKOUT_SESSION_ID}";
        }
        
        if (cancelUrl != null && !cancelUrl.trim().isEmpty()) {
            finalCancelUrl = cancelUrl;
        } else {
            finalCancelUrl = frontendUrl + "/payment-cancel?session_id={CHECKOUT_SESSION_ID}";
        }

        SessionCreateParams params = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(finalSuccessUrl)
                .setCancelUrl(finalCancelUrl)

                .addLineItem(
                        SessionCreateParams.LineItem.builder()
                                .setPriceData(
                                        SessionCreateParams.LineItem.PriceData.builder()
                                                .setCurrency(order.getCurrency().toLowerCase())
                                                .setUnitAmount(amountInCents)
                                                .setProductData(
                                                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                                .setName("Kurs: " + order.getCourseId())
                                                                .setDescription("Sipariş No: " + order.getOrderNumber())
                                                                .build())
                                                .build())
                                .setQuantity(1L)
                                .build())

                .putMetadata("orderId", order.getId().toString())
                .putMetadata("orderNumber", order.getOrderNumber())
                .putMetadata("paymentId", payment.getId().toString())
                .putMetadata("userId", order.getUserId().toString())
                .putMetadata("courseId", order.getCourseId().toString())

                .setCustomerEmail(order.getCustomerEmail())
                .addPaymentMethodType(SessionCreateParams.PaymentMethodType.CARD)

                .build();

        Session session = Session.create(params);

        return session;
    }

    public Session retrieveSession(String sessionId) throws StripeException {
        return Session.retrieve(sessionId);
    }
}

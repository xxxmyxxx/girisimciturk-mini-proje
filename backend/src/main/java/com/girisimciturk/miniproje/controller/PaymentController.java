package com.girisimciturk.miniproje.controller;

import com.girisimciturk.miniproje.dto.*;
import com.girisimciturk.miniproje.model.*;
import com.girisimciturk.miniproje.service.*;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/v1/payment")
@CrossOrigin(origins = "*")
@Tag(name = "Payment", description = "Ödeme işlemleri API (Stripe entegrasyonu)")
public class PaymentController {

    private final PaymentService paymentService;
    private final OrderService orderService;
    private final CourseService courseService;
    private final StripeService stripeService;

    public PaymentController(PaymentService paymentService,
            OrderService orderService,
            CourseService courseService,
            StripeService stripeService) {
        this.paymentService = paymentService;
        this.orderService = orderService;
        this.courseService = courseService;
        this.stripeService = stripeService;
    }

    /**
     * Yeni sipariş oluştur ve Stripe checkout URL al
     */
    @Operation(
        summary = "Sipariş oluştur",
        description = "Yeni sipariş oluşturur, Stripe checkout session başlatır ve ödeme URL'i döner"
    )
    @PostMapping("/create-order")
    public ResponseEntity<ApiResponse<CreateOrderResponse>> createOrder(@RequestBody CreateOrderRequest request) {
        try {
            Optional<Course> courseOpt = courseService.getCourseById(request.getCourseId());
            if (courseOpt.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Kurs bulunamadı"));
            }

            Course course = courseOpt.get();

            Order order = orderService.createOrder(
                request.getUserId(),
                request.getCourseId(),
                course.getPrice(),
                "TRY",
                request.getCustomerEmail(),
                request.getCustomerName()
            );

            Payment payment = paymentService.createPayment(
                order.getId(),
                request.getUserId(),
                request.getCourseId(),
                course.getPrice(),
                "TRY"
            );

            orderService.assignPaymentToOrder(order.getId(), payment.getId());
            orderService.updateOrderStatus(order.getId(), OrderStatus.PENDING_PAYMENT);
            paymentService.updatePaymentStatus(payment.getId(), PaymentStatus.WAITING_FOR_PAYMENT, null, null);

            Session session = stripeService.createCheckoutSession(
                order,
                payment,
                request.getSuccessUrl(),
                request.getCancelUrl()
            );

            paymentService.updateStripeInfo(
                payment.getId(),
                session.getPaymentIntent(),
                session.getId(),
                session.getCustomer()
            );

            CreateOrderResponse response = new CreateOrderResponse(
                true,
                "Sipariş oluşturuldu. Ödeme sayfasına yönlendiriliyorsunuz...",
                order.getId(),
                order.getOrderNumber(),
                session.getUrl(),
                session.getId()
            );

            return ResponseEntity.ok(ApiResponse.success("Sipariş başarıyla oluşturuldu", response));

        } catch (StripeException e) {
            return ResponseEntity.status(500)
                .body(ApiResponse.error("Stripe hatası: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                .body(ApiResponse.error("Sistem hatası: " + e.getMessage()));
        }
    }

    /**
     * Sipariş durumunu sorgula
     */
    @Operation(
        summary = "Sipariş durumu sorgula",
        description = "Sipariş ID'sine göre sipariş ve ödeme durumunu döner"
    )
    @GetMapping("/order/{orderId}")
    public ResponseEntity<ApiResponse<OrderDetailsResponse>> getOrderDetails(@PathVariable Long orderId) {
        Optional<Order> orderOpt = orderService.getOrderById(orderId);

        if (orderOpt.isEmpty()) {
            return ResponseEntity.status(404)
                .body(ApiResponse.error("Sipariş bulunamadı"));
        }

        Order order = orderOpt.get();

        Optional<Course> courseOpt = courseService.getCourseById(order.getCourseId());
        String courseName = courseOpt.map(Course::getTitle).orElse("Bilinmeyen Kurs");

        String paymentStatus = "NONE";
        String transactionId = null;

        if (order.getActivePaymentId() != null) {
            Optional<Payment> paymentOpt = paymentService.getPaymentById(order.getActivePaymentId());
            if (paymentOpt.isPresent()) {
                paymentStatus = paymentOpt.get().getStatus().toString();
                transactionId = paymentOpt.get().getTransactionId();
            }
        }

        OrderDetailsResponse response = new OrderDetailsResponse(
            order.getId(),
            order.getOrderNumber(),
            order.getStatus(),
            order.getAmount(),
            order.getCurrency(),
            order.getCreatedAt(),
            order.getExpiresAt(),
            order.getCourseId(),
            courseName,
            paymentStatus,
            transactionId
        );

        return ResponseEntity.ok(ApiResponse.success("Sipariş detayları başarıyla getirildi", response));
    }
}

package com.girisimciturk.miniproje.service;

import com.girisimciturk.miniproje.model.Order;
import com.girisimciturk.miniproje.model.OrderStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Sipariş Yönetim Servisi
 */
@Service
public class OrderService {

    private final Map<Long, Order> orders = new ConcurrentHashMap<>();
    private final Map<String, Long> orderNumberIndex = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);
    public Order createOrder(Long userId, Long courseId, Double amount, 
                            String currency, String customerEmail, String customerName) {
        Order order = new Order();
        order.setId(idGenerator.getAndIncrement());
        order.setOrderNumber(generateOrderNumber());
        order.setUserId(userId);
        order.setCourseId(courseId);
        order.setAmount(amount);
        order.setCurrency(currency != null ? currency : "TRY");
        order.setExchangeRate(1.0);
        
        order.setStatus(OrderStatus.CREATED);
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());
        order.setExpiresAt(LocalDateTime.now().plusMinutes(30));
        
        order.setCustomerEmail(customerEmail);
        order.setCustomerName(customerName);
        
        orders.put(order.getId(), order);
        orderNumberIndex.put(order.getOrderNumber(), order.getId());
        
        return order;
    }
    private String generateOrderNumber() {
        String datePrefix = LocalDateTime.now().toString().substring(0, 10).replace("-", "");
        String uniquePart = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return "ORD-" + datePrefix + "-" + uniquePart;
    }

    public void updateOrderStatus(Long orderId, OrderStatus newStatus) {
        Order order = orders.get(orderId);
        if (order != null) {
            order.setStatus(newStatus);
            order.setUpdatedAt(LocalDateTime.now());
        }
    }

    public void assignPaymentToOrder(Long orderId, Long paymentId) {
        Order order = orders.get(orderId);
        if (order != null) {
            order.setActivePaymentId(paymentId);
            order.setUpdatedAt(LocalDateTime.now());
        }
    }

    public Optional<Order> getOrderById(Long orderId) {
        return Optional.ofNullable(orders.get(orderId));
    }

    public Optional<Order> getOrderByOrderNumber(String orderNumber) {
        Long orderId = orderNumberIndex.get(orderNumber);
        return orderId != null ? Optional.ofNullable(orders.get(orderId)) : Optional.empty();
    }

    public List<Order> getUserOrders(Long userId) {
        return orders.values().stream()
                .filter(o -> o.getUserId().equals(userId))
                .sorted((o1, o2) -> o2.getCreatedAt().compareTo(o1.getCreatedAt()))
                .toList();
    }

    public List<Order> getSuccessfulOrders(Long userId) {
        return orders.values().stream()
                .filter(o -> o.getUserId().equals(userId) && o.getStatus() == OrderStatus.PAID)
                .toList();
    }
    public void expireOldOrders() {
        LocalDateTime now = LocalDateTime.now();
        orders.values().stream()
                .filter(o -> o.getExpiresAt() != null && o.getExpiresAt().isBefore(now))
                .filter(o -> o.getStatus() == OrderStatus.PENDING_PAYMENT)
                .forEach(o -> updateOrderStatus(o.getId(), OrderStatus.FAILED));
    }
}

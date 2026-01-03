import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/payment_service.dart';
import '../widgets/stripe_test_card_info.dart';

/// Modern Ödeme Dialog'u
///
/// Stripe Checkout ile entegre çalışır
/// Test kart bilgileri ve otomatik doldurma özelliği içerir
class PaymentDialog extends StatefulWidget {
  final int userId;
  final int courseId;
  final String courseName;
  final double coursePrice;
  final String customerEmail;
  final String customerName;
  final VoidCallback onSuccess;

  const PaymentDialog({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
    required this.coursePrice,
    required this.customerEmail,
    required this.customerName,
    required this.onSuccess,
  });

  @override
  State<PaymentDialog> createState() =>
      _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  bool _showTestCards = true; // Geliştirme modunda true
  // Order bilgilerini sakla

  /// Stripe Checkout'a yönlendir
  Future<void> _proceedToCheckout() async {
    setState(() => _isProcessing = true);

    try {
      final currentUri = Uri.base;
      final frontendBaseUrl =
          '${currentUri.scheme}://${currentUri.host}${currentUri.hasPort ? ':${currentUri.port}' : ''}';

      final successUrl =
          '$frontendBaseUrl/payment-success?userId=${widget.userId}&courseId=${widget.courseId}';
      final cancelUrl = '$frontendBaseUrl/payment-cancel';

      final result = await _paymentService.createOrder(
        userId: widget.userId,
        courseId: widget.courseId,
        customerEmail: widget.customerEmail,
        customerName: widget.customerName,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      if (!mounted) return;

      if (result['success']) {
        final checkoutUrl = result['stripeCheckoutUrl'];
        final uri = Uri.parse(checkoutUrl);

        if (await canLaunchUrl(uri)) {
          // Dialog'u kapat
          if (mounted) {
            Navigator.of(context).pop();
          }

          // Küçük bir gecikme ekle (dialog animasyonunun bitmesi için)
          await Future.delayed(
            const Duration(milliseconds: 300),
          );

          // Stripe'a yönlendir - Web için _self kullan (aynı pencerede açılır)
          await launchUrl(uri, webOnlyWindowName: '_self');
        } else {
          throw Exception('URL açılamadı');
        }
      } else {
        _showErrorDialog(
          result['message'] ?? 'Sipariş oluşturulamadı',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Hata dialog'u
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Hata'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(
                        0xFF6366F1,
                      ).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Ödeme',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Kurs bilgisi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Satın Alınan Kurs',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.courseName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Müşteri bilgisi
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.customerName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.customerEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              const Text(
                                'Toplam Tutar:',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '₺${widget.coursePrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Test kartları göster/gizle
                    if (_showTestCards) ...[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Test Kartları',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(
                                () => _showTestCards =
                                    !_showTestCards,
                              );
                            },
                            icon: Icon(
                              _showTestCards
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            label: Text(
                              _showTestCards
                                  ? 'Gizle'
                                  : 'Göster',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const StripeTestCardInfo(),
                      const SizedBox(height: 16),
                    ],

                    // Stripe güvenlik bilgisi
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        border: Border.all(
                          color: Colors.green.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Güvenli Ödeme',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.green[700],
                                  ),
                                ),
                                Text(
                                  'Stripe tarafından güvence altına alınmıştır',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ödeme butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : _proceedToCheckout,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                              )
                            : const Icon(Icons.credit_card),
                        label: Text(
                          _isProcessing
                              ? 'İşleniyor...'
                              : 'Stripe ile Ödeme Yap',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // İptal butonu
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.of(
                                context,
                              ).pop(),
                        child: const Text('İptal'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stripe Test Kart Bilgileri Widget'ı
///
/// Geliştirme ve test aşamasında kullanılacak test kartı bilgilerini gösterir
/// Tek tıkla kopyalama özelliği
class StripeTestCardInfo extends StatelessWidget {
  const StripeTestCardInfo({super.key});

  /// Panoya kopyala ve kullanıcıyı bilgilendir
  void _copyToClipboard(
    BuildContext context,
    String text,
    String label,
  ) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopyalandı: $text'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Test Kart Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Stripe ödeme testleri için kullanın',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const Divider(height: 24),

            // Başarılı kart
            _buildCardInfo(
              context,
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Başarılı Ödeme',
              cardNumber: '4242 4242 4242 4242',
              expiry: '12/34',
              cvv: '123',
            ),
            const SizedBox(height: 12),

            // Reddedilen kart
            _buildCardInfo(
              context,
              icon: Icons.cancel,
              iconColor: Colors.red,
              title: 'Reddedilen Kart',
              cardNumber: '4000 0000 0000 0002',
              expiry: '12/34',
              cvv: '123',
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Kart bilgisi satırı oluştur
  Widget _buildCardInfo(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Kart numarası
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Kart No:',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Text(
                cardNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => _copyToClipboard(
                  context,
                  cardNumber.replaceAll(' ', ''),
                  'Kart numarası',
                ),
                tooltip: 'Kopyala',
              ),
            ],
          ),

          // Son kullanma ve CVV
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'SKT: ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      expiry,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 14,
                      ),
                      onPressed: () => _copyToClipboard(
                        context,
                        expiry.replaceAll('/', ''),
                        'Son kullanma tarihi',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text(
                    'CVV: ',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    cvv,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 14),
                    onPressed: () => _copyToClipboard(
                      context,
                      cvv,
                      'CVV',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

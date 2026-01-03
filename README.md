# 🎓 Girişimci Türk - Mini Proje: Eğitmen-Öğrenci Eşleştirme Platformu

> Udemy + Uber mantığını birleştiren, akıllı eşleştirme algoritması ve profesyonel ödeme entegrasyonu içeren demo platform

---

## 🌐 Canlı Demo

| Servis | URL |
|--------|-----|
| **Frontend** | [verdant-shortbread-a6cd97.netlify.app](https://verdant-shortbread-a6cd97.netlify.app/) |
| **Backend API** | [girisimciturk-mini-proje-production.up.railway.app](https://girisimciturk-mini-proje-production.up.railway.app) |
| **API Docs** | [Swagger UI](https://girisimciturk-mini-proje-production.up.railway.app/swagger-ui.html) |

---

## 🎯 Proje Özeti

Girişimci Türk ekosistemi için hazırlanmış ön eleme mini proje görevi. Sistem 3 temel modülden oluşuyor:

1. **Rol Tabanlı Sistem**: User (Öğrenci), Instructor (Eğitmen), Admin
2. **Kurs Satın Alma**: Stripe entegrasyonu ile Udemy benzeri ödeme akışı
3. **Eğitmen Eşleştirme**: Uber benzeri akıllı eşleştirme algoritması

---

## 🛠 Kullanılan Teknolojiler ve Seçim Nedenleri

### Backend: Java Spring Boot 3.2.0

**Neden Spring Boot?**
- Kurumsal standart (fintech ve bankacılık sektöründe tercih ediliyor)
- Güçlü güvenlik altyapısı (Spring Security)
- Modüler yapı sayesinde kolayca test edilebilir kod
- Mikroservis mimarisine geçiş için ideal
- Swagger/OpenAPI ile otomatik API dokümantasyonu

**Kullanılan Ana Kütüphaneler:**
- Spring Boot Starter Web (REST API)
- Stripe Java SDK (Ödeme entegrasyonu)
- Springdoc OpenAPI (API dokümantasyonu)

### Frontend: Flutter Web

**Neden Flutter?**
- Tek kod ile web, mobil ve desktop desteği
- Native'e yakın performans
- Material Design ile profesyonel UI/UX
- Hot reload ile hızlı geliştirme

### Ödeme: Stripe API

**Neden Stripe?**
- PCI-DSS Level 1 sertifikalı (en yüksek güvenlik standardı)
- Kart bilgileri hiçbir zaman bizim sunucuda saklanmaz
- Webhook desteği ile gerçek zamanlı ödeme bildirimleri
- Mükemmel dokümantasyon ve test ortamı
- Dünya standardı ödeme altyapısı

### Deployment
- **Backend**: Railway.app (otomatik CI/CD, environment variables yönetimi)
- **Frontend**: Netlify (otomatik deploy, CDN desteği, SSL)

---

## 💳 Ödeme Akışı Mantığı

### Neden Bu Yaklaşım En Profesyonel ve Tercih Edilen Yöntem?

Projede **Stripe Checkout Session** modeli kullanılıyor. Bu yaklaşım dünya çapında e-ticaret platformlarında tercih ediliyor çünkü:

#### ✅ 1. Güvenlik (PCI-DSS Uyumluluğu)
- Kullanıcı kart bilgilerini **hiçbir zaman bizim sunucumuza göndermez**
- Tüm hassas bilgiler doğrudan Stripe'ın güvenli sunucularına gider
- Biz sadece `session_id` gibi referans bilgileri saklarız

#### ✅ 2. Güvenilirlik (Webhook Sistemi)
- Kullanıcı tarayıcıyı kapatsa bile ödeme otomatik tamamlanır
- Stripe, ödeme durumunu bizim sunucumuza **bağımsız olarak** bildirir
- Double-payment (çift ödeme) senaryoları engellenir

#### ✅ 3. Tekrar Edilebilirlik (Idempotency)
- Her ödeme için benzersiz `idempotencyKey` oluşturulur
- Kullanıcı yanlışlıkla 3 kere "Ödeme Yap"a basarsa sadece 1 kez ücretlendirilir

#### ✅ 4. Otomatik Süre Dolma
- Checkout session'lar 30 dakika sonra otomatik iptal olur
- Stok/fiyat değişikliklerine karşı koruma sağlar

---

### Ödeme Akışı - Adım Adım

```
┌─────────────┐      ┌──────────────┐      ┌────────────┐      ┌──────────┐
│   Frontend  │─────▶│   Backend    │─────▶│   Stripe   │─────▶│ Webhook  │
│  (Flutter)  │      │ (Spring Boot)│      │  Checkout  │      │ Handler  │
└─────────────┘      └──────────────┘      └────────────┘      └──────────┘
     │                      │                      │                  │
     │ 1. POST              │                      │                  │
     │ /create-order        │                      │                  │
     │─────────────────────▶│                      │                  │
     │                      │                      │                  │
     │                      │ 2. Create            │                  │
     │                      │    Checkout Session  │                  │
     │                      │─────────────────────▶│                  │
     │                      │                      │                  │
     │                      │ 3. Return            │                  │
     │                      │    Checkout URL      │                  │
     │                      │◀─────────────────────│                  │
     │                      │                      │                  │
     │ 4. Return URL        │                      │                  │
     │◀─────────────────────│                      │                  │
     │                      │                      │                  │
     │ 5. User Redirected   │                      │                  │
     │──────────────────────────────────────────────▶                 │
     │     (Stripe Hosted)  │                      │                  │
     │                      │                      │                  │
     │ 6. User Pays         │                      │                  │
     │     (Card Info)      │                      │                  │
     │─────────────────────────────────────────────▶│                  │
     │                      │                      │                  │
     │                      │                      │ 7. Payment Event │
     │                      │                      │  (checkout.      │
     │                      │                      │   session.       │
     │                      │                      │   completed)     │
     │                      │                      │─────────────────▶│
     │                      │                      │                  │
     │                      │ 8. Update Order      │                  │
     │                      │    Assign Course     │                  │
     │                      │◀──────────────────────────────────────────│
     │                      │                      │                  │
     │ 9. Success Page      │                      │                  │
     │◀─────────────────────│                      │                  │
```

### Kritik Kod Noktaları

**1. Checkout Session Oluşturma (PaymentController.java)**
```java
// Order ve Payment oluştur
Order order = orderService.createOrder(userId, courseId, amount, "TRY");
Payment payment = paymentService.createPayment(order.getId(), userId, courseId, amount, "TRY");

// Stripe Checkout Session başlat
Session session = stripeService.createCheckoutSession(order, payment, successUrl, cancelUrl);

// Frontend'e güvenli checkout URL'i gönder
response.setCheckoutUrl(session.getUrl());
```

**2. Webhook ile Ödeme Doğrulama (StripeWebhookController.java)**
```java
@PostMapping("/api/webhook/stripe")
public ResponseEntity<String> handleStripeWebhook(
    @RequestBody String payload,
    @RequestHeader("Stripe-Signature") String sigHeader) {
    
    // 1. Stripe imzasını doğrula (güvenlik)
    Event event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
    
    // 2. Event tipine göre işlem yap
    if (event.getType().equals("checkout.session.completed")) {
        // Ödeme başarılı → Kursu kullanıcıya ata
        paymentService.updatePaymentStatus(paymentId, PaymentStatus.PAID);
        orderService.updateOrderStatus(orderId, OrderStatus.COMPLETED);
        courseService.assignCourseToUser(userId, courseId);
    }
}
```

### Bu Yaklaşımın Avantajları

| Özellik | Alternatif Yaklaşım | Checkout Session |
|---------|---------------------|------------------|
| **Güvenlik** | Kart bilgisi sunucuda | ✅ Kart bilgisi hiç sunucuya gelmez |
| **PCI Compliance** | Ağır sertifikasyon süreci | ✅ Stripe halleder |
| **UI/UX** | Custom form geliştirme | ✅ Stripe'ın optimize UI'ı |
| **Güvenilirlik** | Frontend'e bağımlı | ✅ Webhook ile bağımsız |
| **Hata Yönetimi** | Manuel implementasyon | ✅ Otomatik retry ve timeout |

---

## 🤖 Eşleştirme Algoritması

### Algoritma Prensibi

Sistem, her eğitmeni **4 farklı kritere** göre puanlar ve ağırlıklı ortalama ile final skoru hesaplar:

```java
// MatchingService.java - Ağırlıklandırma
private static final double WEIGHT_RATING = 0.35;          // %35 - En yüksek ağırlık
private static final double WEIGHT_WORKLOAD = 0.25;        // %25
private static final double WEIGHT_AVAILABILITY_SOON = 0.25; // %25
private static final double WEIGHT_AVAILABILITY_FLEX = 0.15; // %15

double finalScore = 
    WEIGHT_RATING * ratingScore +
    WEIGHT_WORKLOAD * workloadScore +
    WEIGHT_AVAILABILITY_SOON * availabilitySoonScore +
    WEIGHT_AVAILABILITY_FLEX * availabilityFlexScore;
```

### Kriter 1: Rating Skoru (%35 Ağırlık)

**Amaç:** En kaliteli eğitmeni bul

```java
double ratingScore = profile.getRating() / 5.0;

// Örnek: 4.8/5 rating → 0.96 skor
```

### Kriter 2: İş Yükü Skoru (%25 Ağırlık)

**Amaç:** Aşırı yüklü eğitmenlerden kaçın

```java
private double calculateWorkloadScore(InstructorProfile profile) {
    int lessonCount = profile.getLessonCountLast30Days();
    double score = 1.0 - (Math.min(lessonCount, 20) / 20.0);
    return Math.max(0, Math.min(1, score));
}

// Örnek:
// 0 ders → 1.00 skor (çok müsait)
// 10 ders → 0.50 skor (orta yüklü)
// 20+ ders → 0.00 skor (çok yoğun)
```

### Kriter 3: Yakın Müsaitlik Skoru (%25 Ağırlık)

**Amaç:** En hızlı başlayabilecek eğitmeni bul

```java
private double calculateAvailabilitySoonScore(InstructorProfile profile) {
    long hoursUntilAvailable = ChronoUnit.HOURS.between(now, profile.getNearestAvailability());
    
    if (hoursUntilAvailable <= 0) return 1.0;  // Şu an müsait
    if (hoursUntilAvailable <= 24) return 0.9; // 24 saat içinde
    if (hoursUntilAvailable <= 48) return 0.7; // 2 gün içinde
    if (hoursUntilAvailable <= 96) return 0.3; // 4 gün içinde
    return 0.0; // 4 günden fazla
}
```

### Kriter 4: Esneklik Skoru (%15 Ağırlık)

**Amaç:** Farklı zaman dilimlerinde ders verebilenleri tercih et

```java
private double calculateAvailabilityFlexScore(InstructorProfile profile) {
    List<TimeSlot> slots = profile.getAvailableTimeSlots();
    
    // Kaç farklı günde müsait?
    Set<String> uniqueDays = slots.stream()
        .map(TimeSlot::getDayOfWeek)
        .collect(Collectors.toSet());
    
    // Slot sayısı ve gün çeşitliliğini dengele
    double slotScore = Math.min(slots.size() / 7.0, 1.0);
    double dayScore = Math.min(uniqueDays.size() / 5.0, 1.0);
    
    return (slotScore + dayScore) / 2.0;
}

// Örnek: 7 slot, 5 farklı gün → 1.00 skor
```

### Gerçek Örnek: 3 Eğitmen Karşılaştırması

Bir öğrenci "Python" dersi talep ettiğinde sistem şöyle puanlar:

| Eğitmen | Rating | İş Yükü | En Yakın Müsaitlik | Esneklik | **Final Skor** |
|---------|--------|---------|-------------------|----------|----------------|
| **Ali** | 4.8/5.0 | 5 ders/ay | Şu an (1.0) | 7 slot, 5 gün | **0.89** ✅ |
| Ayşe | 5.0/5.0 | 18 ders/ay | 48 saat (0.7) | 3 slot, 2 gün | **0.65** |
| Mehmet | 3.5/5.0 | 2 ders/ay | 24 saat (0.9) | 5 slot, 3 gün | **0.79** |

**Detaylı Hesaplama (Ali için):**
```
Rating:    4.8/5 = 0.96 × 0.35 = 0.336
Workload:  5 ders → 0.75 × 0.25 = 0.188
Soon:      Şu an → 1.0 × 0.25 = 0.250
Flex:      Çok esnek → 1.0 × 0.15 = 0.150
──────────────────────────────────────
Final Score = 0.89 (Ali seçilir)
```

### Algoritmanın Güçlü Yönleri

✅ **Dengeli Değerlendirme**: Tek bir kritere bağımlı kalmıyor  
✅ **Esnek Ağırlıklar**: İş gereksinimlerine göre kolayca ayarlanabilir  
✅ **Genişletilebilir**: Yeni kriterler (fiyat, deneyim yılı) kolayca eklenebilir  
✅ **Test Edilebilir**: Her kriter ayrı ayrı unit test edilebilir  
✅ **Şeffaf**: Kullanıcıya hangi kriterlere göre eşleştirildiği gösterilebilir

---

## 📈 Sistemin Gelecekte Nasıl Ölçeklenebileceği

### Veri Katmanı
- In-memory yapıdan **PostgreSQL + JPA**'ya geçiş yapılabilir
- **Redis cache** ile performans %70-90 artırılabilir
- Transaction management ve backup stratejileri eklenebilir

### Mimari Geliştirmeler
- Monolitik yapı **mikroservislere** ayrıştırılabilir (User, Course, Payment, Matching)
- **Event-driven architecture** (RabbitMQ/Kafka) ile asenkron işlemler yapılabilir
- API Gateway ile merkezi routing ve yük dengeleme sağlanabilir

### İleri Seviye Özellikler
- **ML entegrasyonu** ile kullanıcı davranışlarından öğrenen dinamik eşleştirme yapılabilir
- **Prometheus + Grafana + ELK Stack** ile monitoring ve log analizi eklenebilir
- **Kubernetes** ile auto-scaling ve multi-region deployment yapılabilir



**Son Güncelleme:** 3 Ocak 2026  
**Proje Durumu:** ✅ Production'da çalışıyor

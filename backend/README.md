# GirisimciTurk Mini Proje - Backend

Spring Boot tabanlı backend servisi. Eğitmen-öğrenci eşleştirme sistemi ve Stripe ödeme entegrasyonu içerir.

## 🚀 Teknolojiler

- **Java 17**
- **Spring Boot 3.2.0**
- **Stripe API** (Ödeme işlemleri)
- **Maven** (Dependency management)
- **Swagger/OpenAPI** (API dokümantasyonu)

## 📋 Gereksinimler

- Java 17 veya üzeri
- Maven 3.6+

## 🔧 Kurulum

### 1. Repository'yi klonlayın

```bash
git clone <repository-url>
cd girisimciturk-mini-proje/backend
```

### 2. Environment Variables Ayarlayın

Local development için:

```bash
cp src/main/resources/application-local.properties.example src/main/resources/application-local.properties
```

Production için environment variables:

```bash
export STRIPE_SECRET_KEY=sk_test_your_key
export STRIPE_PUBLISHABLE_KEY=pk_test_your_key
export STRIPE_WEBHOOK_SECRET=whsec_your_secret
export FRONTEND_URL=http://localhost:8081
export PORT=8080
```

### 3. Uygulamayı Çalıştırın

```bash
# Maven ile
./mvnw spring-boot:run

# veya profil belirterek
./mvnw spring-boot:run -Dspring-boot.run.profiles=local

# JAR oluşturup çalıştırma
./mvnw clean package
java -jar target/mini-proje-backend-1.0.0.jar
```

Uygulama varsayılan olarak `http://localhost:8080` adresinde çalışacaktır.

## 📚 API Dokümantasyonu

Swagger UI: `http://localhost:8080/swagger-ui.html`

### Ana Endpoint'ler

#### Authentication
- `POST /api/v1/auth/login` - Kullanıcı girişi
- `POST /api/v1/auth/register` - Yeni kullanıcı kaydı

#### Users
- `GET /api/v1/users` - Tüm kullanıcıları listele
- `GET /api/v1/users/{id}` - Kullanıcı detayı
- `PUT /api/v1/users/{id}` - Kullanıcı güncelle

#### Matching (Eşleştirme)
- `POST /api/v1/matching/find-instructors` - Uygun eğitmenleri bul
- `POST /api/v1/matching/request-lesson` - Canlı ders talebi oluştur

#### Payments (Stripe)
- `POST /api/v1/payments/create-order` - Ödeme siparişi oluştur
- `GET /api/v1/payments/order/{orderId}` - Sipariş detayı
- `POST /api/v1/stripe/webhook` - Stripe webhook endpoint

#### Courses
- `GET /api/v1/courses` - Kursları listele
- `GET /api/v1/courses/{id}` - Kurs detayı

## 🏗️ Proje Yapısı

```
backend/
├── src/main/java/com/girisimciturk/miniproje/
│   ├── config/          # Spring yapılandırmaları
│   ├── controller/      # REST API controller'ları
│   ├── dto/             # Data Transfer Objects
│   ├── model/           # Domain modelleri
│   └── service/         # Business logic
└── src/main/resources/
    └── application.properties
```

## 🔒 Güvenlik Notları

- ⚠️ Stripe API anahtarları **ASLA** kaynak kodda saklanmamalıdır
- Production ortamında mutlaka environment variables kullanın
- `application-local.properties` dosyası `.gitignore`'da olduğu için Git'e gönderilmez

## 🚀 Deployment

### Render.com

1. GitHub repository'nizi Render'a bağlayın
2. Web Service oluşturun:

**Build Command:**
```bash
./mvnw clean install -DskipTests
```

**Start Command:**
```bash
java -jar target/mini-proje-backend-1.0.0.jar
```

3. Environment Variables ekleyin:
   - `PORT=8080`
   - `FRONTEND_URL=<netlify-url>`
   - `STRIPE_SECRET_KEY=<your-key>`
   - `STRIPE_PUBLISHABLE_KEY=<your-key>`
   - `STRIPE_WEBHOOK_SECRET=<your-secret>`

## 🧪 Test

```bash
./mvnw test
```

## 📝 License

Bu proje öğrenim amaçlı hazırlanmıştır.

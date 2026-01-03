package com.girisimciturk.miniproje.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Swagger/OpenAPI konfigürasyonu
 */
@Configuration
public class OpenApiConfig {

    @Value("${app.frontend.url:http://localhost:8081}")
    private String frontendUrl;

    @Value("${server.port:8080}")
    private String serverPort;

    @Bean
    public OpenAPI customOpenAPI() {
        // Production server (Railway)
        Server productionServer = new Server();
        productionServer.setUrl("https://girisimciturk-mini-proje-production.up.railway.app");
        productionServer.setDescription("Production Server (Railway)");

        // Local development server
        Server localServer = new Server();
        localServer.setUrl("http://localhost:8080");
        localServer.setDescription("Development Server");

        Info info = new Info()
            .title("GirişimciTürk Mini Proje API")
            .version("1.0.0")
            .description("Udemy + Uber Benzeri Eğitim Platformu API Dokümantasyonu\n\n" +
                "Bu API aşağıdaki özellikleri sağlar:\n" +
                "- **Kullanıcı Kimlik Doğrulama**: Login/Logout işlemleri\n" +
                "- **Kurs Yönetimi**: Kurs listeleme ve satın alma\n" +
                "- **Ödeme İşlemleri**: Stripe entegrasyonu ile güvenli ödeme\n" +
                "- **Akıllı Eşleştirme**: Uber benzeri eğitmen-öğrenci eşleştirme algoritması\n\n" +
                "**Test Kullanıcıları:**\n" +
                "- Öğrenci: student1 / password123\n" +
                "- Eğitmen: instructor1 / password123\n" +
                "- Admin: admin / password123\n\n" +
                "**Stripe Test Kartı:** 4242 4242 4242 4242");

        return new OpenAPI()
            .info(info)
            .servers(List.of(productionServer, localServer));
    }
}

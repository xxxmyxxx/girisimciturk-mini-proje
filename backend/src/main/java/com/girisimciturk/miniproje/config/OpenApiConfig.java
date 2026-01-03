package com.girisimciturk.miniproje.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
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

    @Bean
    public OpenAPI customOpenAPI() {
        Server localServer = new Server();
        localServer.setUrl("http://localhost:8080");
        localServer.setDescription("Development Server");

        Contact contact = new Contact();
        contact.setName("GirişimciTürk Team");
        contact.setEmail("info@girisimciturk.com");
        contact.setUrl("https://girisimciturk.com");

        License license = new License();
        license.setName("MIT License");
        license.setUrl("https://opensource.org/licenses/MIT");

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
                "- Öğrenci: user / 123\n" +
                "- Eğitmen: aliihsan / 123\n" +
                "- Admin: admin / 123\n\n" +
                "**Stripe Test Kartı:** 4242 4242 4242 4242")
            .contact(contact)
            .license(license);

        return new OpenAPI()
            .info(info)
            .servers(List.of(localServer));
    }
}

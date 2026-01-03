package com.girisimciturk.miniproje.config;

import com.girisimciturk.miniproje.service.CourseService;
import com.girisimciturk.miniproje.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Servis Konfigürasyonu
 * Circular dependency'yi çözmek için setter injection kullanır
 */
@Configuration
public class ServiceConfig {

    /**
     * CourseService ve UserService arasındaki circular dependency'yi çöz
     */
    @Bean
    public CourseService courseService(UserService userService) {
        CourseService courseService = new CourseService();
        courseService.setUserService(userService);
        return courseService;
    }
}

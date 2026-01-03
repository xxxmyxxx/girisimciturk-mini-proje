package com.girisimciturk.miniproje.service;

import com.girisimciturk.miniproje.model.Course;
import com.girisimciturk.miniproje.model.User;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Kurs yönetimi servisi
 */
public class CourseService {

        private final Map<Long, Course> courses = new ConcurrentHashMap<>();
        private final Map<Long, Set<Long>> userCourses = new ConcurrentHashMap<>();
        private UserService userService;

        public CourseService() {
                initializeMockCourses();
        }

        public void setUserService(UserService userService) {
                this.userService = userService;
        }

        private void initializeMockCourses() {
                // Ali İhsan Özeroğlu - Finans Eğitimleri
                courses.put(1L, new Course(
                                1L,
                                "Finansal Tablolar Analizi",
                                "Mali tabloların nasıl analiz edileceğini ve yorumlanacağını öğrenin",
                                2L,
                                "Ali İhsan Özeroğlu",
                                899.99,
                                "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&h=600&fit=crop",
                                25,
                                "Orta"));

                courses.put(2L, new Course(
                                2L,
                                "İşletme Sermayesi Yönetimi",
                                "İşletme sermayesini etkin yönetme stratejileri",
                                2L,
                                "Ali İhsan Özeroğlu",
                                799.99,
                                "https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800&h=600&fit=crop",
                                20,
                                "İleri"));

                courses.put(5L, new Course(
                                5L,
                                "Bireysel Yatırımcılar İçin Yatırım Stratejileri",
                                "Finansal piyasalarda başarılı olmanın yolları",
                                2L,
                                "Ali İhsan Özeroğlu",
                                699.99,
                                "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800&h=600&fit=crop",
                                30,
                                "Başlangıç"));

                // Anıl Akın - Satış ve Pazarlama
                courses.put(3L, new Course(
                                3L,
                                "Satış Teknikleri ve Marka Yönetimi",
                                "Etkili satış stratejileri ve marka oluşturma",
                                3L,
                                "Anıl Akın",
                                599.99,
                                "https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop",
                                35,
                                "Orta"));

                courses.put(6L, new Course(
                                6L,
                                "Sunum ve İletişim Becerileri",
                                "Profesyonel sunumlar hazırlama ve etkili iletişim",
                                3L,
                                "Anıl Akın",
                                449.99,
                                "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&h=600&fit=crop",
                                15,
                                "Başlangıç"));

                // Çetin Karakaya - Eğitim Yönetimi
                courses.put(7L, new Course(
                                7L,
                                "Özel Okul ve Kurs Yönetimi",
                                "Eğitim kurumlarının yönetimi ve veli ilişkileri",
                                4L,
                                "Çetin Karakaya",
                                749.99,
                                "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&h=600&fit=crop",
                                28,
                                "İleri"));

                // Faruk Tataş - Proje Yönetimi
                courses.put(8L, new Course(
                                8L,
                                "Proje Yönetimi Temelleri",
                                "Baştan sona proje planlama ve yönetme",
                                6L,
                                "Faruk Tataş",
                                899.99,
                                "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&h=600&fit=crop",
                                40,
                                "Orta"));

                courses.put(9L, new Course(
                                9L,
                                "Tasarım Odaklı Düşünme",
                                "İnovatif çözümler için tasarım düşüncesi yöntemleri",
                                6L,
                                "Faruk Tataş",
                                649.99,
                                "https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=800&h=600&fit=crop",
                                22,
                                "Orta"));

                // Kaşif Koyuncu - Girişimcilik
                courses.put(10L, new Course(
                                10L,
                                "Girişimcilik 101: Sıfırdan Startup",
                                "Girişim fikrinden MVP'ye kadar tüm süreç",
                                7L,
                                "Kaşif Koyuncu",
                                999.99,
                                "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&h=600&fit=crop",
                                50,
                                "Başlangıç"));

                // Nazım Özdemir - Liderlik
                courses.put(11L, new Course(
                                11L,
                                "Liderlik ve Takım Yönetimi",
                                "Etkili liderlik becerileri ve takım kurma",
                                8L,
                                "Nazım Özdemir",
                                849.99,
                                "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop",
                                32,
                                "İleri"));

                courses.put(12L, new Course(
                                12L,
                                "Duygusal Zeka ve Karar Verme",
                                "Zor durumlarda doğru kararlar alma sanatı",
                                8L,
                                "Nazım Özdemir",
                                599.99,
                                "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&h=600&fit=crop",
                                18,
                                "Orta"));

                // Sefer Özdemir - Girişimcilik
                courses.put(13L, new Course(
                                13L,
                                "Girişimcilik Temelleri",
                                "İş fikrinden şirkete dönüşüm rehberi",
                                9L,
                                "Sefer Özdemir",
                                549.99,
                                "https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=800&h=600&fit=crop",
                                20,
                                "Başlangıç"));

                // Ahmet Ergöz - Bilgi Güvenliği
                courses.put(14L, new Course(
                                14L,
                                "Bilgi Güvenliği ve KVKK",
                                "Kurumsal bilgi güvenliği ve KVKK uyumu",
                                10L,
                                "Ahmet Ergöz",
                                799.99,
                                "https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&h=600&fit=crop",
                                30,
                                "İleri"));

                // Murat Sevencan - Devlet Destekleri
                courses.put(15L, new Course(
                                15L,
                                "KOSGEB ve Devlet Destekleri",
                                "Girişimcilerin yararlanabileceği tüm destekler",
                                11L,
                                "Murat Sevencan",
                                499.99,
                                "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800&h=600&fit=crop",
                                15,
                                "Başlangıç"));

                courses.put(16L, new Course(
                                16L,
                                "Kalkınma Ajansı Hibeleri",
                                "Kalkınma ajanslarından nasıl destek alınır",
                                11L,
                                "Murat Sevencan",
                                449.99,
                                "https://images.unsplash.com/photo-1552664730-d307ca884978?w=800&h=600&fit=crop",
                                12,
                                "Başlangıç"));

                // Yasin Anıl - Yazılım Test
                courses.put(4L, new Course(
                                4L,
                                "Selenium ile Test Otomasyonu",
                                "Web uygulamaları için otomatik test yazma",
                                12L,
                                "Yasin Anıl",
                                899.99,
                                "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&h=600&fit=crop",
                                35,
                                "Orta"));

                courses.put(17L, new Course(
                                17L,
                                "Cypress ile Modern Test Yazımı",
                                "Modern JavaScript test framework'ü ile testing",
                                12L,
                                "Yasin Anıl",
                                799.99,
                                "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&h=600&fit=crop",
                                28,
                                "İleri"));
        }

        public List<Course> getAllCourses() {
                return new ArrayList<>(courses.values());
        }

        public Optional<Course> getCourseById(Long id) {
                return Optional.ofNullable(courses.get(id));
        }

        public List<Course> getCoursesByIds(List<Long> courseIds) {
                return courseIds.stream()
                                .map(courses::get)
                                .filter(Objects::nonNull)
                                .collect(Collectors.toList());
        }

        public List<Course> getCoursesByInstructor(Long instructorId) {
                return courses.values().stream()
                                .filter(c -> c.getInstructorId().equals(instructorId))
                                .collect(Collectors.toList());
        }

        public List<Course> getCoursesByInstructorId(Long instructorId) {
                return getCoursesByInstructor(instructorId);
        }

        public boolean assignCourseToUser(Long userId, Long courseId) {
                if (!courses.containsKey(courseId)) {
                        return false;
                }

                Set<Long> userCourseSet = userCourses.computeIfAbsent(userId, k -> ConcurrentHashMap.newKeySet());
                userCourseSet.add(courseId);

                return true;
        }

        public List<Course> getUserCourses(Long userId) {
                Set<Long> courseIds = userCourses.getOrDefault(userId, Collections.emptySet());

                return courseIds.stream()
                                .map(courses::get)
                                .filter(Objects::nonNull)
                                .collect(Collectors.toList());
        }

        public boolean hasUserAccessToCourse(Long userId, Long courseId) {
                Set<Long> courseIds = userCourses.get(userId);
                return courseIds != null && courseIds.contains(courseId);
        }

        public List<User> getStudentsForCourse(Long courseId) {
                List<User> students = new ArrayList<>();

                for (Map.Entry<Long, Set<Long>> entry : userCourses.entrySet()) {
                        Long userId = entry.getKey();
                        Set<Long> userCourseIds = entry.getValue();

                        if (userCourseIds.contains(courseId)) {
                                if (userService != null) {
                                        userService.getUserById(userId).ifPresent(students::add);
                                }
                        }
                }

                return students;
        }
}

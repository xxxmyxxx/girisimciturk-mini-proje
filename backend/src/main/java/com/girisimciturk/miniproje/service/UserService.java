package com.girisimciturk.miniproje.service;

import com.girisimciturk.miniproje.model.InstructorProfile;
import com.girisimciturk.miniproje.model.Role;
import com.girisimciturk.miniproje.model.TimeSlot;
import com.girisimciturk.miniproje.model.User;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Kullanıcı yönetimi servisi
 * Mock data ile kullanıcı işlemlerini yönetir
 */
@Service
public class UserService {

        // In-memory kullanıcı deposu
        private final Map<Long, User> users = new ConcurrentHashMap<>();

        public UserService() {
                initializeMockUsers();
                // Tüm öğretmenleri müsait yap
                setAllInstructorsAvailable();
        }

  
        private void initializeMockUsers() {
                // Normal kullanıcı
                User user1 = new User(1L, "user", "123", "Ahmet Yılmaz", "user@girisimciturk.com", Role.USER,
                                "https://ui-avatars.com/api/?name=Ahmet+Yilmaz&background=6366F1&color=fff",
                                new ArrayList<>(), new ArrayList<>(), true, null);
                users.put(1L, user1);

                // ========== EĞİTMENLER ==========

                // Eğitmen 1: Ali İhsan Özeroğlu - Finans uzmanı
                InstructorProfile profileAliIhsan = new InstructorProfile();
                profileAliIhsan.setInstructorId(2L);
                profileAliIhsan.setTitle("Finans Uzmanı");
                profileAliIhsan.setBio("Mali tablolar ve yatırım konularında 15 yıllık deneyim");
                profileAliIhsan.setExpertiseAreas(Arrays.asList("Finans", "Yatırım", "Mali Tablolar"));
                profileAliIhsan.setRating(4.8);
                profileAliIhsan.setTotalStudents(150);
                profileAliIhsan.setLessonCountLast30Days(15);
                profileAliIhsan.setWorkloadLevel("ORTA");
                profileAliIhsan.setAvailableTimeSlots(generateRandomTimeSlots(5));
                profileAliIhsan.setNearestAvailability(LocalDateTime.now().plusDays(2));

                User instructor1 = new User(2L, "aliihsan", "123", "Ali İhsan Özeroğlu", "aliihsan@girisimciturk.com",
                                Role.INSTRUCTOR,
                                "https://ui-avatars.com/api/?name=Ali+Ihsan&background=8B5CF6&color=fff",
                                new ArrayList<>(), Arrays.asList(1L, 2L, 5L), true, profileAliIhsan);
                users.put(2L, instructor1);

                // Eğitmen 2: Anıl Akın - Satış & Pazarlama
                InstructorProfile profileAnil = new InstructorProfile();
                profileAnil.setInstructorId(3L);
                profileAnil.setTitle("Satış & Pazarlama Uzmanı");
                profileAnil.setBio("Dijital pazarlama ve satış stratejileri konusunda uzman");
                profileAnil.setExpertiseAreas(Arrays.asList("Satış", "Pazarlama", "İletişim"));
                profileAnil.setRating(4.5);
                profileAnil.setTotalStudents(120);
                profileAnil.setLessonCountLast30Days(12);
                profileAnil.setWorkloadLevel("ORTA");
                profileAnil.setAvailableTimeSlots(generateRandomTimeSlots(6));
                profileAnil.setNearestAvailability(LocalDateTime.now().plusDays(1));

                User instructor2 = new User(3L, "anilakin", "123", "Anıl Akın", "anilakin@girisimciturk.com",
                                Role.INSTRUCTOR,
                                "https://ui-avatars.com/api/?name=Anil+Akin&background=EC4899&color=fff",
                                new ArrayList<>(), Arrays.asList(3L, 6L), true, profileAnil);
                users.put(3L, instructor2);

                // Eğitmen 3: Çetin Karakaya - Eğitim Yönetimi
                InstructorProfile profileCetin = new InstructorProfile();
                profileCetin.setInstructorId(4L);
                profileCetin.setTitle("Eğitim Yönetimi Uzmanı");
                profileCetin.setBio("Okul idaresi ve eğitim yönetimi alanında deneyimli");
                profileCetin.setExpertiseAreas(Arrays.asList("Eğitim Yönetimi", "Okul İdaresi"));
                profileCetin.setRating(4.7);
                profileCetin.setTotalStudents(95);
                profileCetin.setLessonCountLast30Days(8);
                profileCetin.setWorkloadLevel("DÜŞÜK");
                profileCetin.setAvailableTimeSlots(generateRandomTimeSlots(8));
                profileCetin.setNearestAvailability(LocalDateTime.now().plusHours(12));

                User instructor3 = new User(4L, "cetinkarakaya", "123", "Çetin Karakaya",
                                "cetinkarakaya@girisimciturk.com", Role.INSTRUCTOR,
                                "https://ui-avatars.com/api/?name=Cetin+Karakaya&background=14B8A6&color=fff",
                                new ArrayList<>(), Arrays.asList(7L), true, profileCetin);
                users.put(4L, instructor3);

                // Eğitmen 4: Faruk Tataş - Proje Yönetimi
                InstructorProfile profileFaruk = new InstructorProfile();
                profileFaruk.setInstructorId(5L);
                profileFaruk.setTitle("Proje Yönetimi Uzmanı");
                profileFaruk.setBio("Agile ve Scrum metodolojileri konusunda sertifikalı");
                profileFaruk.setExpertiseAreas(Arrays.asList("Proje Yönetimi", "Tasarım Düşüncesi"));
                profileFaruk.setRating(4.6);
                profileFaruk.setTotalStudents(110);
                profileFaruk.setLessonCountLast30Days(10);
                profileFaruk.setWorkloadLevel("ORTA");
                profileFaruk.setAvailableTimeSlots(generateRandomTimeSlots(4));
                profileFaruk.setNearestAvailability(LocalDateTime.now().plusDays(3));

                User instructor4 = new User(5L, "faruktatas", "123", "Faruk Tataş", "faruktatas@girisimciturk.com",
                                Role.INSTRUCTOR,
                                "https://ui-avatars.com/api/?name=Faruk+Tatas&background=F97316&color=fff",
                                new ArrayList<>(), Arrays.asList(8L, 9L), true, profileFaruk);
                users.put(5L, instructor4);

                // Diğer eğitmenler basit profille...
                createSimpleInstructor(6L, "kasifkoyuncu", "Kaşif Koyuncu",
                                Arrays.asList(10L), Arrays.asList("Girişimcilik", "Startup"));
                createSimpleInstructor(7L, "nazimozdemir", "Nazım Özdemir",
                                Arrays.asList(11L, 12L), Arrays.asList("Liderlik", "Takım Yönetimi"));
                createSimpleInstructor(8L, "seferozdemir", "Sefer Özdemir",
                                Arrays.asList(13L), Arrays.asList("Girişimcilik"));
                createSimpleInstructor(9L, "ahmetergoz", "Ahmet Ergöz",
                                Arrays.asList(14L), Arrays.asList("Bilgi Güvenliği", "KVKK"));
                createSimpleInstructor(10L, "muratsevencan", "Murat Sevencan",
                                Arrays.asList(15L, 16L), Arrays.asList("KOSGEB", "Devlet Destekleri"));
                createSimpleInstructor(11L, "yasinanil", "Yasin Anıl",
                                Arrays.asList(4L, 17L), Arrays.asList("Test Otomasyonu", "Selenium", "Cypress"));

                // Admin
                User admin = new User(12L, "admin", "123", "Zeynep Yıldız", "admin@girisimciturk.com", Role.ADMIN,
                                "https://ui-avatars.com/api/?name=Zeynep+Yildiz&background=EF4444&color=fff",
                                new ArrayList<>(), new ArrayList<>(), true, null);
                users.put(12L, admin);
        }

        /**
         * Basit eğitmen profili oluştur (diğer eğitmenler için)
         */
        private void createSimpleInstructor(Long id, String username, String fullName,
                        List<Long> courseIds, List<String> expertise) {
                InstructorProfile profile = new InstructorProfile();
                profile.setInstructorId(id);
                profile.setTitle(expertise.get(0) + " Uzmanı");
                profile.setBio(String.join(", ", expertise) + " konularında deneyimli eğitmen");
                profile.setExpertiseAreas(expertise);
                profile.setRating(4.0 + (Math.random() * 0.9));
                profile.setLessonCountLast30Days((int) (Math.random() * 15) + 5);
                profile.setWorkloadLevel("ORTA");
                profile.setAvailableTimeSlots(generateRandomTimeSlots(5));
                profile.setNearestAvailability(LocalDateTime.now().plusDays((long) (Math.random() * 5)));

                String photoUrl = "https://ui-avatars.com/api/?name=" +
                                fullName.replace(" ", "+") +
                                "&background=" +
                                String.format("%06X", (int) (Math.random() * 0xFFFFFF)) +
                                "&color=fff";

                User instructor = new User(id, username, "123", fullName, username + "@girisimciturk.com",
                                Role.INSTRUCTOR,
                                photoUrl, new ArrayList<>(), courseIds, true, profile);
                users.put(id, instructor);
        }

        /**
         * Rastgele zaman slotları oluştur
         */
        private List<TimeSlot> generateRandomTimeSlots(int count) {
                List<TimeSlot> slots = new ArrayList<>();
                LocalDateTime now = LocalDateTime.now();

                for (int i = 0; i < count; i++) {
                        long daysToAdd = (long) (Math.random() * 10);
                        int hour = 9 + (int) (Math.random() * 12); // 9-21 arası

                        LocalDateTime startTime = now.plusDays(daysToAdd).withHour(hour).withMinute(0);
                        LocalDateTime endTime = startTime.plusHours(1);

                        slots.add(new TimeSlot((long) (100 + i), startTime, endTime, true, "Gün " + i));
                }

                return slots;
        }

        /**
         * Kullanıcı adı ve şifre ile giriş kontrolü
         */
        public Optional<User> authenticate(String username, String password) {
                return users.values().stream()
                                .filter(u -> u.getUsername().equals(username) && u.getPassword().equals(password))
                                .findFirst();
        }

        /**
         * ID ile kullanıcı getir
         */
        public Optional<User> getUserById(Long id) {
                return Optional.ofNullable(users.get(id));
        }

        /**
         * Tüm kullanıcıları getir
         */
        public List<User> getAllUsers() {
                return new ArrayList<>(users.values());
        }

        /**
         * Sadece eğitmenleri getir
         */
        public List<User> getInstructors() {
                return users.values().stream()
                                .filter(u -> u.getRole() == Role.INSTRUCTOR)
                                .toList();
        }

        /**
         * Müsait eğitmenleri getir
         */
        public List<User> getAvailableInstructors() {
                return users.values().stream()
                                .filter(u -> u.getRole() == Role.INSTRUCTOR && u.isAvailable())
                                .toList();
        }

        /**
         * Kullanıcıya kurs ekle (satın alma sonrası)
         */
        public void addCourseToUser(Long userId, Long courseId) {
                User user = users.get(userId);
                if (user != null && !user.getPurchasedCourseIds().contains(courseId)) {
                        user.getPurchasedCourseIds().add(courseId);
                }
        }

        /**
         * Kullanıcının satın aldığı kurs ID'lerini getir
         */
        public List<Long> getUserCourseIds(Long userId) {
                User user = users.get(userId);
                return user != null ? user.getPurchasedCourseIds() : new ArrayList<>();
        }

        /**
         * Tüm öğretmenleri müsait yap
         */
        public void setAllInstructorsAvailable() {
                users.values().stream()
                                .filter(u -> u.getRole() == Role.INSTRUCTOR)
                                .forEach(u -> u.setAvailable(true));
        }
}

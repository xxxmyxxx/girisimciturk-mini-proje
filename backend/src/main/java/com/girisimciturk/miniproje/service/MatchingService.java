package com.girisimciturk.miniproje.service;

import com.girisimciturk.miniproje.dto.InstructorComparisonDTO;
import com.girisimciturk.miniproje.dto.LiveLessonRequestDTO;
import com.girisimciturk.miniproje.model.InstructorProfile;
import com.girisimciturk.miniproje.model.LiveLessonRequest;
import com.girisimciturk.miniproje.model.TimeSlot;
import com.girisimciturk.miniproje.model.User;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

/**
 * Canlı ders eşleştirme servisi
 */
@Service
public class MatchingService {

    private final Map<Long, LiveLessonRequest> requests = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);
    private final UserService userService;
    private final CourseService courseService;

    private static final double WEIGHT_RATING = 0.35;
    private static final double WEIGHT_WORKLOAD = 0.25;
    private static final double WEIGHT_AVAILABILITY_SOON = 0.25;
    private static final double WEIGHT_AVAILABILITY_FLEX = 0.15;

    public MatchingService(UserService userService, CourseService courseService) {
        this.userService = userService;
        this.courseService = courseService;
    }

    public LiveLessonRequest createLessonRequest(LiveLessonRequestDTO requestDTO) {
        
        LiveLessonRequest request = new LiveLessonRequest();
        request.setId(idGenerator.getAndIncrement());
        request.setUserId(requestDTO.getUserId());
        request.setCourseId(requestDTO.getCourseId());
        request.setTopic(requestDTO.getTopic());
        request.setLevel(requestDTO.getLevel());
        request.setPreferredDateTime(requestDTO.getPreferredDateTime());
        request.setInstructorSuggestsTime(requestDTO.isInstructorSuggestsTime());
        request.setRequestDate(LocalDateTime.now());
        request.setStatus("PENDING");

        // Kullanıcı ve kurs bilgilerini al
        userService.getUserById(requestDTO.getUserId()).ifPresent(user -> 
            request.setUserName(user.getFullName())
        );
        
        courseService.getCourseById(requestDTO.getCourseId()).ifPresent(course -> 
            request.setCourseName(course.getTitle())
        );

        List<User> candidateInstructors = findInstructorsByCourse(requestDTO.getCourseId());

        if (candidateInstructors.isEmpty()) {
            request.setStatus("NO_INSTRUCTOR_FOUND");
            requests.put(request.getId(), request);
            return request;
        }

        if (candidateInstructors.size() == 1) {
            User instructor = candidateInstructors.get(0);
            assignInstructorToRequest(request, instructor);
            requests.put(request.getId(), request);
            return request;
        }

        User bestInstructor = selectBestInstructor(candidateInstructors, request);
        
        if (bestInstructor != null) {
            assignInstructorToRequest(request, bestInstructor);
        } else {
            request.setStatus("NO_SUITABLE_INSTRUCTOR");
        }

        requests.put(request.getId(), request);
        return request;
    }

    private void assignInstructorToRequest(LiveLessonRequest request, User instructor) {
        request.setAssignedInstructorId(instructor.getId());
        request.setAssignedInstructorName(instructor.getFullName());
        
        InstructorProfile profile = instructor.getInstructorProfile();
        if (profile != null) {
            request.setMatchingScore(profile.getMatchingScore());
        }

        if (request.isInstructorSuggestsTime() || request.getPreferredDateTime() == null) {
            List<TimeSlot> suggestedSlots = suggestTimeSlots(instructor, 3);
            request.setSuggestedTimeSlots(suggestedSlots);
            request.setStatus("TIME_SUGGESTED");
        } else {
            request.setStatus("MATCHED");
            request.setMatchedDate(LocalDateTime.now());
        }

        sendNotificationToInstructor(instructor, request);
    }
    private List<User> findInstructorsByCourse(Long courseId) {
        // Kursu al
        Optional<com.girisimciturk.miniproje.model.Course> courseOpt = courseService.getCourseById(courseId);
        if (courseOpt.isEmpty()) {
            return new ArrayList<>();
        }
        
        com.girisimciturk.miniproje.model.Course course = courseOpt.get();
        Long instructorId = course.getInstructorId();
        
        // Bu kursu veren eğitmeni döndür
        return userService.getUserById(instructorId)
                .map(Collections::singletonList)
                .orElse(new ArrayList<>());
    }

    private List<User> findInstructorsByTopic(String topic) {
        if (topic == null || topic.trim().isEmpty()) {
            return userService.getAvailableInstructors();
        }
        
        final String topicLower = topic.toLowerCase();
        
        return userService.getAvailableInstructors().stream()
                .filter(instructor -> {
                    InstructorProfile profile = instructor.getInstructorProfile();
                    if (profile == null || profile.getExpertiseAreas() == null) {
                        return false;
                    }
                    
                    return profile.getExpertiseAreas().stream()
                            .filter(expertise -> expertise != null && !expertise.trim().isEmpty())
                            .anyMatch(expertise -> {
                                String expertiseLower = expertise.toLowerCase();
                                return expertiseLower.contains(topicLower) ||
                                       topicLower.contains(expertiseLower);
                            });
                })
                .collect(Collectors.toList());
    }
    private User selectBestInstructor(List<User> candidates, LiveLessonRequest request) {
        if (candidates == null || candidates.isEmpty()) {
            return null;
        }

        User bestInstructor = null;
        double bestScore = -1;

        for (User candidate : candidates) {
            double score = calculateMatchingScore(candidate, request);
            
            if (candidate.getInstructorProfile() != null) {
                candidate.getInstructorProfile().setMatchingScore(score);
            }

            if (score > bestScore) {
                bestScore = score;
                bestInstructor = candidate;
            }
        }

        return bestInstructor;
    }
    private double calculateMatchingScore(User instructor, LiveLessonRequest request) {
        InstructorProfile profile = instructor.getInstructorProfile();
        
        if (profile == null) {
            return 0.0;
        }

        double ratingScore = profile.getRating() / 5.0;
        double workloadScore = calculateWorkloadScore(profile);
        double availabilitySoonScore = calculateAvailabilitySoonScore(profile);
        double availabilityFlexScore = calculateAvailabilityFlexScore(profile);

        double finalScore = 
            WEIGHT_RATING * ratingScore +
            WEIGHT_WORKLOAD * workloadScore +
            WEIGHT_AVAILABILITY_SOON * availabilitySoonScore +
            WEIGHT_AVAILABILITY_FLEX * availabilityFlexScore;

        return Math.round(finalScore * 100.0) / 100.0;
    }
    private double calculateWorkloadScore(InstructorProfile profile) {
        int lessonCount = profile.getLessonCountLast30Days();
        double score = 1.0 - (Math.min(lessonCount, 20) / 20.0);
        return Math.max(0, Math.min(1, score));
    }
    private double calculateAvailabilitySoonScore(InstructorProfile profile) {
        if (profile.getNearestAvailability() == null) {
            return 0.0;
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nearest = profile.getNearestAvailability();
        
        long hoursUntilAvailable = ChronoUnit.HOURS.between(now, nearest);
        
        if (hoursUntilAvailable <= 0) return 1.0;
        if (hoursUntilAvailable <= 24) return 0.9;
        if (hoursUntilAvailable <= 48) return 0.7;
        if (hoursUntilAvailable <= 96) return 0.3;
        
        return 0.0;
    }
    private double calculateAvailabilityFlexScore(InstructorProfile profile) {
        List<TimeSlot> slots = profile.getAvailableTimeSlots();
        
        if (slots == null || slots.isEmpty()) {
            return 0.0;
        }

        Set<String> uniqueDays = slots.stream()
                .map(TimeSlot::getDayOfWeek)
                .collect(Collectors.toSet());

        int slotCount = slots.size();
        int dayCount = uniqueDays.size();
        
        double slotScore = Math.min(slotCount / 7.0, 1.0);
        double dayScore = Math.min(dayCount / 5.0, 1.0);
        
        return (slotScore + dayScore) / 2.0;
    }
    private List<TimeSlot> suggestTimeSlots(User instructor, int count) {
        if (instructor.getInstructorProfile() == null) {
            return new ArrayList<>();
        }

        List<TimeSlot> availableSlots = instructor.getInstructorProfile().getAvailableTimeSlots();
        
        if (availableSlots == null || availableSlots.isEmpty()) {
            return new ArrayList<>();
        }

        return availableSlots.stream()
                .filter(TimeSlot::isAvailable)
                .sorted(Comparator.comparing(TimeSlot::getStartTime))
                .limit(count)
                .collect(Collectors.toList());
    }
    public boolean selectTimeSlot(Long requestId, Long slotId) {
        LiveLessonRequest request = requests.get(requestId);
        
        if (request == null || !"TIME_SUGGESTED".equals(request.getStatus())) {
            return false;
        }

        Optional<TimeSlot> selectedSlot = request.getSuggestedTimeSlots().stream()
                .filter(slot -> slot.getId().equals(slotId))
                .findFirst();

        if (selectedSlot.isEmpty()) {
            return false;
        }

        request.setSelectedTimeSlot(selectedSlot.get());
        request.setStatus("CONFIRMED");
        request.setConfirmedDate(LocalDateTime.now());
        request.setMatchedDate(LocalDateTime.now());

        return true;
    }
    public List<InstructorComparisonDTO> compareInstructors(String topic) {
        List<User> candidates = findInstructorsByTopic(topic);
        
        return candidates.stream()
                .map(instructor -> {
                    InstructorProfile profile = instructor.getInstructorProfile();
                    if (profile == null) {
                        return null;
                    }

                    LiveLessonRequest dummyRequest = new LiveLessonRequest();
                    dummyRequest.setTopic(topic);
                    double score = calculateMatchingScore(instructor, dummyRequest);

                    InstructorComparisonDTO dto = new InstructorComparisonDTO();
                    dto.setInstructorId(instructor.getId());
                    dto.setInstructorName(instructor.getFullName());
                    dto.setRating(profile.getRating());
                    dto.setWorkloadLevel(profile.getWorkloadLevel());
                    dto.setAvailableSlotCount(profile.getAvailableTimeSlots() != null ? 
                            profile.getAvailableTimeSlots().size() : 0);
                    dto.setNearestAvailability(profile.getNearestAvailability() != null ?
                            profile.getNearestAvailability().toString() : "Yok");
                    dto.setSlotDistribution(calculateSlotDistribution(profile));
                    dto.setFinalScore(score);
                    dto.setReasoning(buildScoreReasoning(profile, score));

                    return dto;
                })
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(InstructorComparisonDTO::getFinalScore).reversed())
                .collect(Collectors.toList());
    }

    private String calculateSlotDistribution(InstructorProfile profile) {
        List<TimeSlot> slots = profile.getAvailableTimeSlots();
        
        if (slots == null || slots.isEmpty()) {
            return "Yok";
        }

        Set<String> uniqueDays = slots.stream()
                .map(TimeSlot::getDayOfWeek)
                .collect(Collectors.toSet());

        return slots.size() + " slot / " + uniqueDays.size() + " farklı gün";
    }

    private String buildScoreReasoning(InstructorProfile profile, double finalScore) {
        return String.format(
            "Rating: %.1f/5.0 (%.0f%%) | " +
            "İş Yükü: %s (%d ders) | " +
            "En Yakın: %s | " +
            "Esneklik: %d slot → Final Skor: %.2f",
            profile.getRating(), 
            (profile.getRating() / 5.0) * 100,
            profile.getWorkloadLevel(),
            profile.getLessonCountLast30Days(),
            profile.getNearestAvailability() != null ? 
                profile.getNearestAvailability().toString() : "Yok",
            profile.getAvailableTimeSlots() != null ? 
                profile.getAvailableTimeSlots().size() : 0,
            finalScore
        );
    }

    private void sendNotificationToInstructor(User instructor, LiveLessonRequest request) {
    }

    public List<LiveLessonRequest> getAllRequests() {
        return new ArrayList<>(requests.values());
    }
    public List<LiveLessonRequest> getUserRequests(Long userId) {
        return requests.values().stream()
                .filter(r -> r.getUserId().equals(userId))
                .sorted((r1, r2) -> r2.getRequestDate().compareTo(r1.getRequestDate()))
                .toList();
    }

    public List<LiveLessonRequest> getInstructorRequests(Long instructorId) {
        return requests.values().stream()
                .filter(r -> instructorId.equals(r.getAssignedInstructorId()))
                .sorted((r1, r2) -> r2.getRequestDate().compareTo(r1.getRequestDate()))
                .toList();
    }

    public Optional<LiveLessonRequest> getRequestById(Long requestId) {
        return Optional.ofNullable(requests.get(requestId));
    }
}

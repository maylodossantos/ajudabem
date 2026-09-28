package com.ajudabem.api.services.notification;

import com.ajudabem.api.domains.notification.Notification;
import com.ajudabem.api.domains.notification.NotificationType;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.notification.NotificationResponseDTO;
import com.ajudabem.api.dto.notification.UnreadCountDTO;
import com.ajudabem.api.exceptions.NotificationNotFoundException;
import com.ajudabem.api.mappers.NotificationMapper;
import com.ajudabem.api.repositories.NotificationRepository;
import com.ajudabem.api.repositories.OrganizationRepository;
import com.ajudabem.api.repositories.UserRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository repository;
    private final UserRepository userRepository;
    private final OrganizationRepository organizationRepository;
    private final CurrentUserService currentUserService;
    private final NotificationMapper mapper;

    public void notify(User recipient, NotificationType type, String title, String message, Long targetId) {
        if (recipient == null) {
            return;
        }
        Notification notification = new Notification();
        notification.setRecipient(recipient);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setTargetId(targetId);
        repository.save(notification);
    }

    public void notifyAll(Collection<User> recipients, User except, NotificationType type, String title,
                          String message, Long targetId) {
        recipients.stream()
                .filter(recipient -> except == null || !Objects.equals(recipient.getId(), except.getId()))
                .forEach(recipient -> notify(recipient, type, title, message, targetId));
    }

    public void notifyEveryone(User except, NotificationType type, String title, String message, Long targetId) {
        notifyAll(userRepository.findAll(), except, type, title, message, targetId);
    }

    public void notifyApprovedOrganizations(NotificationType type, String title, String message, Long targetId) {
        notifyAll(organizationRepository.findAllByStatusOrderBySubmittedAtDesc(OrganizationStatus.APPROVED).stream()
                .map(Organization::getOwner)
                .toList(), null, type, title, message, targetId);
    }

    public List<NotificationResponseDTO> mine() {
        return repository.findTop100ByRecipientOrderByCreatedAtDesc(currentUserService.get()).stream()
                .map(mapper::toResponse)
                .toList();
    }

    public UnreadCountDTO unreadCount() {
        return new UnreadCountDTO(repository.countByRecipientAndReadAtIsNull(currentUserService.get()));
    }

    @Transactional
    public NotificationResponseDTO markRead(Long id) {
        User user = currentUserService.get();
        Notification notification = repository.findById(id)
                .filter(found -> Objects.equals(found.getRecipient().getId(), user.getId()))
                .orElseThrow(() -> new NotificationNotFoundException("Notification not found"));
        if (notification.getReadAt() == null) {
            notification.setReadAt(LocalDateTime.now());
            repository.save(notification);
        }
        return mapper.toResponse(notification);
    }

    @Transactional
    public void markAllRead() {
        LocalDateTime now = LocalDateTime.now();
        List<Notification> unread = repository.findAllByRecipientAndReadAtIsNull(currentUserService.get());
        unread.forEach(notification -> notification.setReadAt(now));
        repository.saveAll(unread);
    }
}

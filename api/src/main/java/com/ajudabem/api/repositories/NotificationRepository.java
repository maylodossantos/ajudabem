package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.notification.Notification;
import com.ajudabem.api.domains.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {

    List<Notification> findTop100ByRecipientOrderByCreatedAtDesc(User recipient);

    List<Notification> findAllByRecipientAndReadAtIsNull(User recipient);

    long countByRecipientAndReadAtIsNull(User recipient);
}

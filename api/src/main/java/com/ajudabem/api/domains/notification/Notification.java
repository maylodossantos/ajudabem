package com.ajudabem.api.domains.notification;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.user.User;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class Notification extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "recipient_user_id", nullable = false)
    private User recipient;

    @Enumerated(EnumType.STRING)
    private NotificationType type;

    private String title;
    private String message;
    private Long targetId;
    private LocalDateTime readAt;
}

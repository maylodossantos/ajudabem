package com.ajudabem.api.dto.notification;

import com.ajudabem.api.domains.notification.NotificationType;

import java.time.LocalDateTime;

public record NotificationResponseDTO(
        Long id,
        NotificationType type,
        String title,
        String message,
        Long targetId,
        LocalDateTime createdAt,
        LocalDateTime readAt
) { }

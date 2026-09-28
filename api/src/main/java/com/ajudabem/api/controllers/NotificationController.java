package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.notification.NotificationResponseDTO;
import com.ajudabem.api.dto.notification.UnreadCountDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.notification.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/notification")
@Tag(name = "Notifications")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class NotificationController {

    private final NotificationService notificationService;

    @Operation(summary = "My latest notifications")
    @GetMapping
    public ResponseEntity<List<NotificationResponseDTO>> mine() {
        return ResponseEntity.ok(notificationService.mine());
    }

    @Operation(summary = "How many of my notifications are unread")
    @GetMapping("/unread-count")
    public ResponseEntity<UnreadCountDTO> unreadCount() {
        return ResponseEntity.ok(notificationService.unreadCount());
    }

    @Operation(summary = "Mark one notification as read")
    @PostMapping("/{id}/read")
    public ResponseEntity<NotificationResponseDTO> markRead(@PathVariable Long id) {
        return ResponseEntity.ok(notificationService.markRead(id));
    }

    @Operation(summary = "Mark every notification as read")
    @PostMapping("/read-all")
    public ResponseEntity<Void> markAllRead() {
        notificationService.markAllRead();
        return ResponseEntity.noContent().build();
    }
}

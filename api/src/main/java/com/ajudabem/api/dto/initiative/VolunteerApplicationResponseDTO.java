package com.ajudabem.api.dto.initiative;

import com.ajudabem.api.domains.initiative.ApplicationStatus;

import java.time.LocalDateTime;

public record VolunteerApplicationResponseDTO(
        Long id,
        Long volunteerId,
        String name,
        String profileImage,
        String phone,
        ApplicationStatus status,
        LocalDateTime createdAt
) { }

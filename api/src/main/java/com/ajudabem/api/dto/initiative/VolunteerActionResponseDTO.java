package com.ajudabem.api.dto.initiative;

import com.ajudabem.api.domains.initiative.ApplicationStatus;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.dto.organization.OrganizationSummaryDTO;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record VolunteerActionResponseDTO(
        Long id,
        String title,
        LocalDate date,
        LocalTime startTime,
        LocalTime endTime,
        Integer volunteersNeeded,
        long acceptedCount,
        long pendingCount,
        String street,
        String number,
        String city,
        String state,
        String zipCode,
        String description,
        String tasks,
        String requirements,
        String notes,
        InitiativeStatus status,
        OrganizationSummaryDTO organization,
        ApplicationStatus myApplication,
        OrganizationContactDTO contact,
        LocalDateTime finishedAt
) { }

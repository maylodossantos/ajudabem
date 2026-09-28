package com.ajudabem.api.dto.initiative;

import com.ajudabem.api.domains.initiative.CampaignCategory;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.dto.organization.OrganizationSummaryDTO;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record CampaignResponseDTO(
        Long id,
        String title,
        String donationInfo,
        String subtitle,
        String description,
        CampaignCategory category,
        BigDecimal goalAmount,
        LocalDate deadline,
        String coverImage,
        InitiativeStatus status,
        OrganizationSummaryDTO organization,
        LocalDateTime createdAt,
        LocalDateTime finishedAt
) { }

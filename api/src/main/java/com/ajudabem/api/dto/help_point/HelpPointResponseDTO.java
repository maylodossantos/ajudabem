package com.ajudabem.api.dto.help_point;

import com.ajudabem.api.domains.help_point.AssistanceType;
import com.ajudabem.api.domains.help_point.HelpPointOrganizationType;
import com.ajudabem.api.domains.help_point.HelpPointSource;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

public record HelpPointResponseDTO(
        Long id,
        String name,
        String description,
        String coverImage,
        HelpPointOrganizationType organizationType,
        Set<AssistanceType> services,
        String street,
        String number,
        String neighborhood,
        String city,
        String state,
        String zipCode,
        Double latitude,
        Double longitude,
        String phone,
        String whatsapp,
        String email,
        String responsible,
        List<OpeningHoursDTO> openingHours,
        String scheduleNote,
        String notes,
        HelpPointSource source,
        LocalDateTime createdAt
) { }

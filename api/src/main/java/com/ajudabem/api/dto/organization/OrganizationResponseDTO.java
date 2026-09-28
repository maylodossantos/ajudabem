package com.ajudabem.api.dto.organization;

import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.organization.RejectionReason;
import com.ajudabem.api.dto.user.UserResponseSummaryDTO;

import java.time.LocalDateTime;
import java.util.List;

public record OrganizationResponseDTO(
        Long id,
        UserResponseSummaryDTO owner,
        String corporateName,
        String tradeName,
        String cnpj,
        String activityArea,
        String street,
        String number,
        String neighborhood,
        String city,
        String state,
        String zipCode,
        Double latitude,
        Double longitude,
        String website,
        String instagram,
        OrganizationStatus status,
        LocalDateTime submittedAt,
        LocalDateTime reviewedAt,
        RejectionReason rejectionReason,
        String rejectionNote,
        LocalDateTime resubmitAvailableAt,
        List<OrganizationDocumentResponseDTO> documents
) { }

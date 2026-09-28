package com.ajudabem.api.dto.organization;

import com.ajudabem.api.domains.organization.OrganizationDocumentType;

import java.time.LocalDateTime;

public record OrganizationDocumentResponseDTO(
        OrganizationDocumentType type,
        String fileName,
        Long sizeBytes,
        LocalDateTime sentAt
) { }

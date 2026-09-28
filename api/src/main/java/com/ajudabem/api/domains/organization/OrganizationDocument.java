package com.ajudabem.api.domains.organization;

import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Embeddable
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OrganizationDocument {

    @Enumerated(EnumType.STRING)
    private OrganizationDocumentType type;

    private String fileName;

    private String contentType;

    private Long sizeBytes;

    private LocalDateTime sentAt;
}

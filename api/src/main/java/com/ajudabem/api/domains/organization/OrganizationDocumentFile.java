package com.ajudabem.api.domains.organization;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Entity
@Table(name = "organization_document_files")
@IdClass(OrganizationDocumentFile.Key.class)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OrganizationDocumentFile {

    public static final int MAX_SIZE_BYTES = 10 * 1024 * 1024;

    @Id
    private Long organizationId;

    @Id
    @Enumerated(EnumType.STRING)
    private OrganizationDocumentType type;

    @Column(nullable = false, length = MAX_SIZE_BYTES)
    private byte[] content;

    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    public static class Key implements Serializable {
        private Long organizationId;
        private OrganizationDocumentType type;
    }
}

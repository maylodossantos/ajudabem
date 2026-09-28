package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.organization.OrganizationDocumentFile;
import com.ajudabem.api.domains.organization.OrganizationDocumentType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OrganizationDocumentFileRepository
        extends JpaRepository<OrganizationDocumentFile, OrganizationDocumentFile.Key> {

    Optional<OrganizationDocumentFile> findByOrganizationIdAndType(Long organizationId, OrganizationDocumentType type);
}

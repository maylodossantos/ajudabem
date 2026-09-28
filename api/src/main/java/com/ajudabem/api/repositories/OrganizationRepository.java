package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrganizationRepository extends JpaRepository<Organization, Long> {

    Optional<Organization> findByOwner(User owner);

    Optional<Organization> findByCnpj(String cnpj);

    List<Organization> findAllByOrderBySubmittedAtDesc();

    List<Organization> findAllByStatusOrderBySubmittedAtDesc(OrganizationStatus status);
}

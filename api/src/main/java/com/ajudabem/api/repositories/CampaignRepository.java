package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.initiative.Campaign;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.domains.organization.Organization;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CampaignRepository extends JpaRepository<Campaign, Long> {

    List<Campaign> findAllByStatusOrderByCreatedAtDesc(InitiativeStatus status);

    List<Campaign> findAllByOrganizationOrderByCreatedAtDesc(Organization organization);

    long countByOrganizationAndStatus(Organization organization, InitiativeStatus status);
}

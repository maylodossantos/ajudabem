package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.domains.initiative.VolunteerAction;
import com.ajudabem.api.domains.organization.Organization;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface VolunteerActionRepository extends JpaRepository<VolunteerAction, Long> {

    List<VolunteerAction> findAllByStatusAndDateGreaterThanEqualOrderByDateAscStartTimeAsc(
            InitiativeStatus status, LocalDate from);

    List<VolunteerAction> findAllByOrganizationOrderByDateDescStartTimeDesc(Organization organization);
}

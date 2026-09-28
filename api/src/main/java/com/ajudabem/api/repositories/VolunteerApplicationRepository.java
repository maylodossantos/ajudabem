package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.initiative.ApplicationStatus;
import com.ajudabem.api.domains.initiative.VolunteerAction;
import com.ajudabem.api.domains.initiative.VolunteerApplication;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.user.User;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VolunteerApplicationRepository extends JpaRepository<VolunteerApplication, Long> {

    Optional<VolunteerApplication> findByActionAndVolunteer(VolunteerAction action, User volunteer);

    List<VolunteerApplication> findAllByActionOrderByCreatedAtAsc(VolunteerAction action);

    List<VolunteerApplication> findAllByVolunteer(User volunteer);

    long countByActionAndStatus(VolunteerAction action, ApplicationStatus status);

    @Query("select count(distinct a.volunteer) from VolunteerApplication a "
            + "where a.action.organization = :organization and a.status = :status")
    long countVolunteers(@Param("organization") Organization organization, @Param("status") ApplicationStatus status);
}

package com.ajudabem.api.services.impact;

import com.ajudabem.api.domains.care.CareStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.ajudabem.api.domains.initiative.ApplicationStatus;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.dto.impact.OrganizationImpactDTO;
import com.ajudabem.api.dto.impact.PlatformImpactDTO;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.CampaignRepository;
import com.ajudabem.api.repositories.VolunteerApplicationRepository;
import com.ajudabem.api.services.organization.OrganizationAccessService;
import com.ajudabem.api.services.user.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ImpactService {

    private final AssistedPersonRepository personRepository;
    private final CampaignRepository campaignRepository;
    private final VolunteerApplicationRepository applicationRepository;
    private final CurrentUserService currentUserService;
    private final OrganizationAccessService organizationAccess;

    public PlatformImpactDTO platform() {
        return new PlatformImpactDTO(
                personRepository.count(),
                personRepository.countByCareStatus(CareStatus.IN_CARE),
                personRepository.countByCareStatusAndFinishReason(CareStatus.FINISHED, FinishReason.HELPED));
    }

    public OrganizationImpactDTO organization() {
        Organization organization = organizationAccess.approvedOf(currentUserService.get());
        return new OrganizationImpactDTO(
                personRepository.countByOrganization(organization),
                applicationRepository.countVolunteers(organization, ApplicationStatus.ACCEPTED),
                campaignRepository.countByOrganizationAndStatus(organization, InitiativeStatus.FINISHED));
    }
}

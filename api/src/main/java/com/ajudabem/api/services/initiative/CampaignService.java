package com.ajudabem.api.services.initiative;

import com.ajudabem.api.domains.initiative.Campaign;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.dto.initiative.CampaignRequestDTO;
import com.ajudabem.api.dto.initiative.CampaignResponseDTO;
import com.ajudabem.api.exceptions.CampaignNotFoundException;
import com.ajudabem.api.exceptions.InitiativeClosedException;
import com.ajudabem.api.mappers.InitiativeMapper;
import com.ajudabem.api.repositories.CampaignRepository;
import com.ajudabem.api.domains.notification.NotificationType;
import com.ajudabem.api.services.notification.NotificationService;
import com.ajudabem.api.services.organization.OrganizationAccessService;
import com.ajudabem.api.services.user.CurrentUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CampaignService {

    private final CampaignRepository repository;
    private final InitiativeMapper mapper;
    private final CurrentUserService currentUserService;
    private final OrganizationAccessService organizationAccess;
    private final NotificationService notificationService;

    public List<CampaignResponseDTO> active() {
        LocalDate today = LocalDate.now();
        return repository.findAllByStatusOrderByCreatedAtDesc(InitiativeStatus.ACTIVE).stream()
                .filter(campaign -> campaign.getDeadline() == null || !campaign.getDeadline().isBefore(today))
                .map(mapper::toResponse)
                .toList();
    }

    public CampaignResponseDTO get(Long id) {
        return mapper.toResponse(findCampaign(id));
    }

    public List<CampaignResponseDTO> mine() {
        Organization organization = organizationAccess.approvedOf(currentUserService.get());
        return repository.findAllByOrganizationOrderByCreatedAtDesc(organization).stream()
                .map(mapper::toResponse)
                .toList();
    }

    @Transactional
    public CampaignResponseDTO create(CampaignRequestDTO dto) {
        Campaign campaign = new Campaign();
        campaign.setOrganization(organizationAccess.approvedOf(currentUserService.get()));
        mapper.apply(dto, campaign);
        repository.save(campaign);

        Organization organization = campaign.getOrganization();
        notificationService.notifyEveryone(organization.getOwner(), NotificationType.CAMPAIGN_CREATED,
                "Nova campanha criada",
                "A ONG " + organization.getTradeName() + " iniciou a campanha “" + campaign.getTitle() + "”.",
                campaign.getId());
        return mapper.toResponse(campaign);
    }

    @Transactional
    public CampaignResponseDTO update(Long id, CampaignRequestDTO dto) {
        Campaign campaign = ownedOpenCampaign(id);
        mapper.apply(dto, campaign);
        repository.save(campaign);
        return mapper.toResponse(campaign);
    }

    @Transactional
    public CampaignResponseDTO finish(Long id) {
        Campaign campaign = ownedOpenCampaign(id);
        campaign.setStatus(InitiativeStatus.FINISHED);
        campaign.setFinishedAt(LocalDateTime.now());
        repository.save(campaign);
        return mapper.toResponse(campaign);
    }

    private Campaign ownedOpenCampaign(Long id) {
        Organization organization = organizationAccess.approvedOf(currentUserService.get());
        Campaign campaign = findCampaign(id);
        OrganizationAccessService.requireSame(campaign.getOrganization(), organization);
        if (campaign.getStatus() == InitiativeStatus.FINISHED) {
            throw new InitiativeClosedException("Initiative already finished");
        }
        return campaign;
    }

    private Campaign findCampaign(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new CampaignNotFoundException("Campaign not found"));
    }
}

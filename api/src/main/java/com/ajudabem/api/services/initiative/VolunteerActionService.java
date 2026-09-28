package com.ajudabem.api.services.initiative;

import com.ajudabem.api.domains.initiative.ApplicationStatus;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.domains.initiative.VolunteerAction;
import com.ajudabem.api.domains.initiative.VolunteerApplication;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.initiative.OrganizationContactDTO;
import com.ajudabem.api.dto.initiative.VolunteerActionRequestDTO;
import com.ajudabem.api.dto.initiative.VolunteerActionResponseDTO;
import com.ajudabem.api.dto.initiative.VolunteerApplicationResponseDTO;
import com.ajudabem.api.exceptions.ActionFullException;
import com.ajudabem.api.exceptions.AlreadyAppliedException;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.InitiativeClosedException;
import com.ajudabem.api.exceptions.VolunteerActionNotFoundException;
import com.ajudabem.api.exceptions.VolunteerApplicationNotFoundException;
import com.ajudabem.api.infra.validation.Digits;
import com.ajudabem.api.mappers.InitiativeMapper;
import com.ajudabem.api.repositories.VolunteerActionRepository;
import com.ajudabem.api.repositories.VolunteerApplicationRepository;
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
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VolunteerActionService {

    private final VolunteerActionRepository repository;
    private final VolunteerApplicationRepository applicationRepository;
    private final InitiativeMapper mapper;
    private final CurrentUserService currentUserService;
    private final OrganizationAccessService organizationAccess;
    private final NotificationService notificationService;

    public List<VolunteerActionResponseDTO> open() {
        User user = currentUserService.get();
        Map<Long, ApplicationStatus> mine = applicationRepository.findAllByVolunteer(user).stream()
                .collect(Collectors.toMap(application -> application.getAction().getId(),
                        VolunteerApplication::getStatus, (first, second) -> first));

        return repository.findAllByStatusAndDateGreaterThanEqualOrderByDateAscStartTimeAsc(
                        InitiativeStatus.ACTIVE, LocalDate.now()).stream()
                .map(action -> toResponse(action, mine.get(action.getId())))
                .toList();
    }

    public VolunteerActionResponseDTO get(Long id) {
        User user = currentUserService.get();
        VolunteerAction action = findAction(id);
        ApplicationStatus myApplication = applicationRepository.findByActionAndVolunteer(action, user)
                .map(VolunteerApplication::getStatus)
                .orElse(null);
        return toResponse(action, myApplication);
    }

    public List<VolunteerActionResponseDTO> mine() {
        Organization organization = organizationAccess.approvedOf(currentUserService.get());
        return repository.findAllByOrganizationOrderByDateDescStartTimeDesc(organization).stream()
                .map(action -> toResponse(action, null))
                .toList();
    }

    @Transactional
    public VolunteerActionResponseDTO create(VolunteerActionRequestDTO dto) {
        VolunteerAction action = new VolunteerAction();
        action.setOrganization(organizationAccess.approvedOf(currentUserService.get()));
        apply(dto, action);
        repository.save(action);

        Organization organization = action.getOrganization();
        notificationService.notifyEveryone(organization.getOwner(), NotificationType.ACTION_CREATED,
                "Nova ação voluntária",
                "A ONG " + organization.getTradeName() + " precisa de voluntários para “" + action.getTitle() + "”.",
                action.getId());
        return toResponse(action, null);
    }

    @Transactional
    public VolunteerActionResponseDTO update(Long id, VolunteerActionRequestDTO dto) {
        VolunteerAction action = ownedOpenAction(id);
        apply(dto, action);
        repository.save(action);
        return toResponse(action, null);
    }

    @Transactional
    public VolunteerActionResponseDTO finish(Long id) {
        VolunteerAction action = ownedOpenAction(id);
        action.setStatus(InitiativeStatus.FINISHED);
        action.setFinishedAt(LocalDateTime.now());
        repository.save(action);
        return toResponse(action, null);
    }

    @Transactional
    public VolunteerActionResponseDTO apply(Long id) {
        User user = currentUserService.get();
        VolunteerAction action = requireOpen(findAction(id));
        boolean ownAction = organizationAccess.of(user)
                .map(organization -> Objects.equals(organization.getId(), action.getOrganization().getId()))
                .orElse(false);
        if (ownAction) {
            throw new ForbiddenActionException("Organizations cannot apply to their own actions");
        }
        if (applicationRepository.findByActionAndVolunteer(action, user).isPresent()) {
            throw new AlreadyAppliedException("Already applied to this action");
        }
        requireVacancy(action);

        VolunteerApplication application = new VolunteerApplication();
        application.setAction(action);
        application.setVolunteer(user);
        applicationRepository.save(application);

        notificationService.notify(action.getOrganization().getOwner(), NotificationType.VOLUNTEER_APPLIED,
                "Novo voluntário",
                user.getName() + " se candidatou para “" + action.getTitle() + "”.",
                action.getId());
        return toResponse(action, application.getStatus());
    }

    @Transactional
    public VolunteerActionResponseDTO withdraw(Long id) {
        User user = currentUserService.get();
        VolunteerAction action = findAction(id);
        VolunteerApplication application = applicationRepository.findByActionAndVolunteer(action, user)
                .orElseThrow(() -> new VolunteerApplicationNotFoundException("Application not found"));
        application.softDelete();
        applicationRepository.save(application);
        return toResponse(action, null);
    }

    public List<VolunteerApplicationResponseDTO> volunteers(Long id) {
        VolunteerAction action = ownedAction(id);
        return applicationRepository.findAllByActionOrderByCreatedAtAsc(action).stream()
                .map(mapper::toResponse)
                .toList();
    }

    @Transactional
    public VolunteerApplicationResponseDTO accept(Long id, Long applicationId) {
        VolunteerAction action = requireOpen(ownedAction(id));
        VolunteerApplication application = applicationRepository.findById(applicationId)
                .filter(found -> Objects.equals(found.getAction().getId(), action.getId()))
                .orElseThrow(() -> new VolunteerApplicationNotFoundException("Application not found"));
        if (application.getStatus() != ApplicationStatus.ACCEPTED) {
            requireVacancy(action);
            application.setStatus(ApplicationStatus.ACCEPTED);
            applicationRepository.save(application);
            notificationService.notify(application.getVolunteer(), NotificationType.APPLICATION_ACCEPTED,
                    "Candidatura aceita",
                    "Você foi aceito na ação “" + action.getTitle() + "” da ONG "
                            + action.getOrganization().getTradeName() + ".",
                    action.getId());
        }
        return mapper.toResponse(application);
    }

    private void apply(VolunteerActionRequestDTO dto, VolunteerAction action) {
        mapper.apply(dto, action);
        action.setState(dto.state().toUpperCase());
        action.setZipCode(dto.zipCode() == null ? null : Digits.only(dto.zipCode()));
    }

    private VolunteerActionResponseDTO toResponse(VolunteerAction action, ApplicationStatus myApplication) {
        User owner = action.getOrganization().getOwner();
        OrganizationContactDTO contact = myApplication == ApplicationStatus.ACCEPTED
                ? new OrganizationContactDTO(owner.getPhone(), owner.getEmail())
                : null;
        return mapper.toResponse(action,
                applicationRepository.countByActionAndStatus(action, ApplicationStatus.ACCEPTED),
                applicationRepository.countByActionAndStatus(action, ApplicationStatus.PENDING),
                myApplication,
                contact);
    }

    private void requireVacancy(VolunteerAction action) {
        long accepted = applicationRepository.countByActionAndStatus(action, ApplicationStatus.ACCEPTED);
        if (accepted >= action.getVolunteersNeeded()) {
            throw new ActionFullException("No vacancies left");
        }
    }

    private static VolunteerAction requireOpen(VolunteerAction action) {
        if (action.getStatus() == InitiativeStatus.FINISHED) {
            throw new InitiativeClosedException("Initiative already finished");
        }
        return action;
    }

    private VolunteerAction ownedOpenAction(Long id) {
        return requireOpen(ownedAction(id));
    }

    private VolunteerAction ownedAction(Long id) {
        Organization organization = organizationAccess.approvedOf(currentUserService.get());
        VolunteerAction action = findAction(id);
        OrganizationAccessService.requireSame(action.getOrganization(), organization);
        return action;
    }

    private VolunteerAction findAction(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new VolunteerActionNotFoundException("Volunteer action not found"));
    }
}

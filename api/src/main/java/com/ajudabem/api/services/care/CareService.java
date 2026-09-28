package com.ajudabem.api.services.care;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.care.CareRecord;
import com.ajudabem.api.domains.care.CareRecordStatus;
import com.ajudabem.api.domains.care.CareStatus;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.care.CareCaseDetailResponseDTO;
import com.ajudabem.api.dto.care.CareCaseResponseDTO;
import com.ajudabem.api.dto.care.CareRecordRequestDTO;
import com.ajudabem.api.exceptions.AssistedPersonNotFoundException;
import com.ajudabem.api.exceptions.CaseAlreadyAssumedException;
import com.ajudabem.api.exceptions.CaseClosedException;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.mappers.CareMapper;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.CareRecordRepository;
import com.ajudabem.api.repositories.TagRepository;
import com.ajudabem.api.domains.notification.NotificationType;
import com.ajudabem.api.services.notification.NotificationService;
import com.ajudabem.api.services.organization.OrganizationAccessService;
import com.ajudabem.api.services.user.CurrentUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CareService {

    private final AssistedPersonRepository personRepository;
    private final CareRecordRepository recordRepository;
    private final OrganizationAccessService organizationAccess;
    private final NotificationService notificationService;
    private final TagRepository tagRepository;
    private final CurrentUserService currentUserService;
    private final CareMapper mapper;

    public List<CareCaseResponseDTO> nominated() {
        User user = currentUserService.get();
        requireCareTeam(user);
        Organization origin = organizationOf(user);

        return personRepository.findAllByCareStatusOrderByCreatedAtDesc(CareStatus.NOMINATED).stream()
                .map(person -> toCase(person, origin))
                .toList();
    }

    public List<CareCaseResponseDTO> map() {
        User user = currentUserService.get();
        requireCareTeam(user);
        Organization origin = organizationOf(user);

        return personRepository.findAllByCareStatusInAndLatitudeIsNotNull(
                        List.of(CareStatus.NOMINATED, CareStatus.IN_CARE)).stream()
                .map(person -> toCase(person, origin))
                .toList();
    }

    public List<CareCaseResponseDTO> myCases() {
        User user = currentUserService.get();
        if (user.getRole() == UserRole.ADMIN) {
            return personRepository.findAllByCareStatusInOrderByCareUpdatedAtDesc(
                            List.of(CareStatus.IN_CARE, CareStatus.FINISHED)).stream()
                    .map(mapper::toCase)
                    .toList();
        }

        Organization organization = organizationAccess.approvedOf(user);
        return personRepository.findAllByOrganizationOrderByCareUpdatedAtDesc(organization).stream()
                .map(person -> toCase(person, organization))
                .toList();
    }

    public CareCaseDetailResponseDTO get(Long personId) {
        User user = currentUserService.get();
        requireCareTeam(user);
        return detailOf(findPerson(personId), organizationOf(user));
    }

    @Transactional
    public CareCaseResponseDTO assume(Long personId) {
        Organization organization = organizationAccess.approvedOf(currentUserService.get());
        AssistedPerson person = findPerson(personId);
        if (person.getCareStatus() != CareStatus.NOMINATED) {
            throw new CaseAlreadyAssumedException("Case already assumed");
        }

        LocalDateTime now = LocalDateTime.now();
        person.setOrganization(organization);
        person.setCareStatus(CareStatus.IN_CARE);
        person.setCareStartedAt(now);
        person.setCareUpdatedAt(now);
        personRepository.save(person);

        notificationService.notify(person.getAuthor(), NotificationType.CASE_ASSUMED,
                "Sua indicação foi atendida",
                "A ONG " + organization.getTradeName() + " assumiu o atendimento de " + person.getFull_name() + ".",
                person.getId());
        return mapper.toCase(person);
    }

    @Transactional
    public CareCaseDetailResponseDTO addRecord(Long personId, CareRecordRequestDTO dto) {
        User user = currentUserService.get();
        Organization organization = organizationAccess.approvedOf(user);
        AssistedPerson person = findPerson(personId);

        OrganizationAccessService.requireSame(person.getOrganization(), organization);
        if (person.getCareStatus() == CareStatus.FINISHED) {
            throw new CaseClosedException("Case already finished");
        }

        CareRecord record = new CareRecord();
        record.setAssistedPerson(person);
        record.setAuthor(user);
        record.setNumber(recordRepository.countByAssistedPerson(person) + 1);
        record.setStatus(dto.status());
        record.setOccurredAt(dto.occurredAt());
        record.setSituation(dto.situation());
        record.setActionTaken(dto.actionTaken());
        record.setReferral(dto.referral());
        record.setNextStep(dto.nextStep());
        record.setSummary(dto.summary());
        record.setNote(dto.note());
        record.setFinishReason(dto.status() == CareRecordStatus.FINISHED ? dto.finishReason() : null);
        recordRepository.save(record);

        if (dto.tagIds() != null) {
            person.setTags(tagRepository.findAllById(dto.tagIds()));
        }
        if (dto.status() == CareRecordStatus.FINISHED) {
            person.setCareStatus(CareStatus.FINISHED);
            person.setFinishReason(dto.finishReason());
            notificationService.notify(person.getAuthor(), NotificationType.CASE_FINISHED,
                    "Atendimento finalizado",
                    "A ONG " + organization.getTradeName() + " finalizou o atendimento de "
                            + person.getFull_name() + ".",
                    person.getId());
        }
        person.setCareUpdatedAt(LocalDateTime.now());
        personRepository.save(person);

        return detailOf(person, organization);
    }

    private CareCaseDetailResponseDTO detailOf(AssistedPerson person, Organization origin) {
        return new CareCaseDetailResponseDTO(
                toCase(person, origin),
                recordRepository.findAllByAssistedPersonOrderByNumberAsc(person).stream()
                        .map(mapper::toRecord)
                        .toList());
    }

    private CareCaseResponseDTO toCase(AssistedPerson person, Organization origin) {
        boolean located = origin != null && origin.getLatitude() != null && person.getLatitude() != null;
        return mapper.toCase(person).withDistanceKm(located
                ? GeoDistance.km(origin.getLatitude(), origin.getLongitude(), person.getLatitude(), person.getLongitude())
                : null);
    }

    private Organization organizationOf(User user) {
        return organizationAccess.of(user).orElse(null);
    }

    private static void requireCareTeam(User user) {
        if (user.getRole() != UserRole.ADMIN && user.getRole() != UserRole.USER_ONG) {
            throw new ForbiddenActionException("Only organizations and admins can see the cases");
        }
    }

    private AssistedPerson findPerson(Long id) {
        return personRepository.findById(id)
                .orElseThrow(() -> new AssistedPersonNotFoundException("Assisted person not found"));
    }
}

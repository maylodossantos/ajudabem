package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.assited_person.AssistedPersonRequestDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonResponseDTO;
import com.ajudabem.api.exceptions.AssistedPersonNotFoundException;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.mappers.AssistedPersonMapper;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.TagRepository;
import com.ajudabem.api.domains.notification.NotificationType;
import com.ajudabem.api.services.help_point.GeocodingService;
import com.ajudabem.api.services.notification.NotificationService;
import com.ajudabem.api.services.organization.OrganizationAccessService;
import com.ajudabem.api.services.user.CurrentUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AssistedPersonService {

    private final AssistedPersonRepository assistedPersonRepository;
    private final CurrentUserService currentUserService;
    private final TagRepository tagRepository;
    private final AssistedPersonMapper mapper;
    private final GeocodingService geocodingService;
    private final NotificationService notificationService;
    private final OrganizationAccessService organizationAccess;

    @Transactional
    public AssistedPersonResponseDTO createAssistedPerson(AssistedPersonRequestDTO dto) {

        User user = currentUserService.get();

        AssistedPerson assistedPerson = mapper.toEntity(dto);

        applyIdentity(dto, assistedPerson);
        assistedPerson.setAuthor(user);
        assistedPerson.setRiskLevel(null);
        assistedPerson.setTags(tagRepository.findAllById(dto.tagIds()));
        locate(assistedPerson);

        assistedPersonRepository.save(assistedPerson);

        String place = StringUtils.hasText(assistedPerson.getNeighborhood())
                ? " no bairro " + assistedPerson.getNeighborhood()
                : "";
        notificationService.notifyApprovedOrganizations(NotificationType.CASE_NOMINATED,
                "Novo caso indicado", "Uma pessoa precisa de ajuda" + place + ".", assistedPerson.getId());

        return mapper.toResponse(assistedPerson);
    }

    @Transactional
    public AssistedPersonResponseDTO updateAssistedPerson(AssistedPersonRequestDTO dto, Long id) {

        AssistedPerson assistedPerson = findOwnAssistedPerson(id);

        mapper.updateEntity(dto, assistedPerson);
        applyIdentity(dto, assistedPerson);
        assistedPerson.setTags(tagRepository.findAllById(dto.tagIds()));
        assistedPerson.setRiskLevel(null);
        locate(assistedPerson);

        assistedPersonRepository.save(assistedPerson);

        return mapper.toResponse(assistedPerson);
    }

    public List<AssistedPersonResponseDTO> getAllFromCurrentUser() {
        return assistedPersonRepository.findAllByAuthor(currentUserService.get())
                .stream()
                .map(mapper::toResponse)
                .toList();
    }

    public AssistedPersonResponseDTO getAssistedPerson(Long id) {
        AssistedPerson assistedPerson = findAssistedPerson(id);
        User user = currentUserService.get();

        if (!isAuthor(user, assistedPerson)) {
            if (user.getRole() != UserRole.ADMIN && user.getRole() != UserRole.USER_ONG) {
                throw new ForbiddenActionException("Only the author can access this assisted person");
            }
            organizationAccess.requireCaseAccess(user, assistedPerson);
        }

        return mapper.toResponse(assistedPerson);
    }

    @Transactional
    public void deleteAssistedPerson(Long id) {
        AssistedPerson assistedPerson = findOwnAssistedPerson(id);

        assistedPerson.softDelete();
        assistedPersonRepository.save(assistedPerson);
    }

    private AssistedPerson findAssistedPerson(Long id) {
        return assistedPersonRepository.findById(id)
                .orElseThrow(() -> new AssistedPersonNotFoundException("Assisted person not found"));
    }

    private AssistedPerson findOwnAssistedPerson(Long id) {
        AssistedPerson assistedPerson = findAssistedPerson(id);

        if (!isAuthor(currentUserService.get(), assistedPerson)) {
            throw new ForbiddenActionException("Only the author can change this assisted person");
        }

        return assistedPerson;
    }

    private static boolean isAuthor(User user, AssistedPerson assistedPerson) {
        return assistedPerson.getAuthor() != null && assistedPerson.getAuthor().getId().equals(user.getId());
    }

    private static void applyIdentity(AssistedPersonRequestDTO dto, AssistedPerson person) {
        if (dto.isUnidentified()) {
            person.setFull_name(AssistedPersonRequestDTO.UNIDENTIFIED_NAME);
            person.setAge(null);
            person.setGender(null);
        }
    }

    private void locate(AssistedPerson person) {
        boolean hasAddress = StringUtils.hasText(person.getStreet()) && StringUtils.hasText(person.getCity());
        if (hasAddress) {
            person.setLocationDescription(null);
        }

        var coordinates = hasAddress
                ? geocodingService.locate(person.getStreet(), person.getNumber(), person.getCity(),
                        person.getState(), person.getZip_code())
                : cityCenter(person);
        person.setLatitude(coordinates.map(GeocodingService.Coordinates::latitude).orElse(null));
        person.setLongitude(coordinates.map(GeocodingService.Coordinates::longitude).orElse(null));
        person.setLocationPending(!hasAddress && StringUtils.hasText(person.getLocationDescription()));
    }

    private Optional<GeocodingService.Coordinates> cityCenter(AssistedPerson person) {
        if (!StringUtils.hasText(person.getCity())) {
            return Optional.empty();
        }
        String state = StringUtils.hasText(person.getState()) ? ", " + person.getState() : "";
        return geocodingService.search(person.getCity() + state + ", Brasil");
    }
}

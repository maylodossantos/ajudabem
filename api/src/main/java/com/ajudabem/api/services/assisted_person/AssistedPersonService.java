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
import com.ajudabem.api.services.user.CurrentUserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class AssistedPersonService {

    /** Besides the author, these roles can view (never change) anyone's registrations. */
    private static final Set<UserRole> ROLES_THAT_SEE_EVERYONE = Set.of(UserRole.ADMIN, UserRole.USER_ONG);

    private final AssistedPersonRepository assistedPersonRepository;
    private final CurrentUserService currentUserService;
    private final TagRepository tagRepository;
    private final AssistedPersonMapper mapper;

    @Transactional
    public AssistedPersonResponseDTO createAssistedPerson(AssistedPersonRequestDTO dto) {

        User user = currentUserService.get();

        AssistedPerson assistedPerson = mapper.toEntity(dto);

        assistedPerson.setAuthor(user);
        // No risk level yet: RiskTriageService picks pending people up.
        assistedPerson.setRiskLevel(null);
        assistedPerson.setTags(tagRepository.findAllById(dto.tagIds()));

        assistedPersonRepository.save(assistedPerson);

        return mapper.toResponse(assistedPerson);
    }

    @Transactional
    public AssistedPersonResponseDTO updateAssistedPerson(AssistedPersonRequestDTO dto, Long id) {

        AssistedPerson assistedPerson = findOwnAssistedPerson(id);

        mapper.updateEntity(dto, assistedPerson);
        assistedPerson.setTags(tagRepository.findAllById(dto.tagIds()));
        // The description or needs may have changed: back to pending triage.
        assistedPerson.setRiskLevel(null);

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

        if (!isAuthor(user, assistedPerson) && !ROLES_THAT_SEE_EVERYONE.contains(user.getRole())) {
            throw new ForbiddenActionException("Only the author can access this assisted person");
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

    /** For changes: only whoever registered the person may edit or delete it. */
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
}

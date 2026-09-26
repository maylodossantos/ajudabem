package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.*;
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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AssistedPersonServiceTest {

    @Mock
    private AssistedPersonRepository assistedPersonRepository;

    @Mock
    private CurrentUserService currentUserService;

    @Mock
    private TagRepository tagRepository;

    @Mock
    private AssistedPersonMapper mapper;

    @InjectMocks
    private AssistedPersonService assistedPersonService;

    private static User user(Long id, UserRole role) {
        User user = new User();
        user.setId(id);
        user.setRole(role);
        return user;
    }

    private static final User AUTHOR = user(10L, UserRole.USER);

    private static AssistedPerson personBy(User author, Long id) {
        AssistedPerson person = new AssistedPerson();
        person.setId(id);
        person.setAuthor(author);
        person.setDeleted(false);
        return person;
    }

    private AssistedPersonRequestDTO requestDTO() {
        return new AssistedPersonRequestDTO(
                "John Doe", 30, Gender.MALE, List.of(1L, 2L), "notes",
                "street", "1", "neighborhood", "city", "state", "zip", "country"
        );
    }

    @Test
    void createAssistedPerson_shouldSetAuthorAndTagsAndLeaveRiskPendingTriage_thenSave() {
        User author = new User();
        author.setId(10L);

        AssistedPersonRequestDTO dto = requestDTO();
        AssistedPerson entity = new AssistedPerson();

        Tag tag1 = new Tag();
        tag1.setId(1L);
        Tag tag2 = new Tag();
        tag2.setId(2L);

        AssistedPersonResponseDTO expected = mock(AssistedPersonResponseDTO.class);

        when(currentUserService.get()).thenReturn(author);
        when(mapper.toEntity(dto)).thenReturn(entity);
        when(tagRepository.findAllById(dto.tagIds())).thenReturn(List.of(tag1, tag2));
        when(mapper.toResponse(entity)).thenReturn(expected);

        AssistedPersonResponseDTO result = assistedPersonService.createAssistedPerson(dto);

        assertThat(result).isEqualTo(expected);
        assertThat(entity.getAuthor()).isEqualTo(author);
        assertThat(entity.getRiskLevel()).isNull();
        assertThat(entity.getTags()).containsExactly(tag1, tag2);
        verify(assistedPersonRepository).save(entity);
    }

    @Test
    void updateAssistedPerson_shouldUpdateFieldsReplaceTagsAndResetRiskToPending() {
        Long id = 5L;
        AssistedPersonRequestDTO dto = requestDTO();
        AssistedPerson entity = personBy(AUTHOR, id);
        entity.setRiskLevel(RiskLevel.HIGH);

        Tag tag1 = new Tag();
        tag1.setId(1L);

        AssistedPersonResponseDTO expected = mock(AssistedPersonResponseDTO.class);

        when(assistedPersonRepository.findById(id)).thenReturn(Optional.of(entity));
        when(currentUserService.get()).thenReturn(AUTHOR);
        when(tagRepository.findAllById(dto.tagIds())).thenReturn(List.of(tag1));
        when(mapper.toResponse(entity)).thenReturn(expected);

        AssistedPersonResponseDTO result = assistedPersonService.updateAssistedPerson(dto, id);

        assertThat(result).isEqualTo(expected);
        assertThat(entity.getTags()).containsExactly(tag1);
        assertThat(entity.getRiskLevel()).isNull();
        verify(mapper).updateEntity(dto, entity);
        verify(assistedPersonRepository).save(entity);
    }

    @Test
    void updateAssistedPerson_shouldThrowAssistedPersonNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(assistedPersonRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> assistedPersonService.updateAssistedPerson(requestDTO(), id))
                .isInstanceOf(AssistedPersonNotFoundException.class)
                .hasMessage("Assisted person not found");
    }

    @Test
    void updateAssistedPerson_shouldThrowForbidden_whenCurrentUserIsNotTheAuthor() {
        when(assistedPersonRepository.findById(5L)).thenReturn(Optional.of(personBy(AUTHOR, 5L)));
        when(currentUserService.get()).thenReturn(user(99L, UserRole.ADMIN));

        assertThatThrownBy(() -> assistedPersonService.updateAssistedPerson(requestDTO(), 5L))
                .isInstanceOf(ForbiddenActionException.class);

        verify(assistedPersonRepository, never()).save(any());
    }

    @Test
    void getAllFromCurrentUser_shouldOnlyMapPeopleRegisteredByTheTokenUser() {
        User currentUser = new User();
        currentUser.setId(10L);
        AssistedPerson person1 = new AssistedPerson();
        person1.setId(1L);
        AssistedPerson person2 = new AssistedPerson();
        person2.setId(2L);

        AssistedPersonResponseDTO response1 = mock(AssistedPersonResponseDTO.class);
        AssistedPersonResponseDTO response2 = mock(AssistedPersonResponseDTO.class);

        when(currentUserService.get()).thenReturn(currentUser);
        when(assistedPersonRepository.findAllByAuthor(currentUser)).thenReturn(List.of(person1, person2));
        when(mapper.toResponse(person1)).thenReturn(response1);
        when(mapper.toResponse(person2)).thenReturn(response2);

        List<AssistedPersonResponseDTO> result = assistedPersonService.getAllFromCurrentUser();

        assertThat(result).containsExactly(response1, response2);
        verify(assistedPersonRepository, never()).findAll();
    }

    @Test
    void getAssistedPerson_shouldReturnMappedResponse_whenIdExists() {
        Long id = 7L;
        AssistedPerson entity = personBy(AUTHOR, id);
        AssistedPersonResponseDTO expected = mock(AssistedPersonResponseDTO.class);

        when(assistedPersonRepository.findById(id)).thenReturn(Optional.of(entity));
        when(currentUserService.get()).thenReturn(AUTHOR);
        when(mapper.toResponse(entity)).thenReturn(expected);

        AssistedPersonResponseDTO result = assistedPersonService.getAssistedPerson(id);

        assertThat(result).isEqualTo(expected);
    }

    @Test
    void getAssistedPerson_shouldLetAdminsAndOngsViewAnyonesRegistration() {
        AssistedPerson entity = personBy(AUTHOR, 7L);
        when(assistedPersonRepository.findById(7L)).thenReturn(Optional.of(entity));

        for (UserRole role : List.of(UserRole.ADMIN, UserRole.USER_ONG)) {
            when(currentUserService.get()).thenReturn(user(99L, role));

            assistedPersonService.getAssistedPerson(7L);
        }

        verify(mapper, times(2)).toResponse(entity);
    }

    @Test
    void getAssistedPerson_shouldThrowForbidden_whenAnotherRegularUserAsks() {
        when(assistedPersonRepository.findById(7L)).thenReturn(Optional.of(personBy(AUTHOR, 7L)));
        when(currentUserService.get()).thenReturn(user(99L, UserRole.USER));

        assertThatThrownBy(() -> assistedPersonService.getAssistedPerson(7L))
                .isInstanceOf(ForbiddenActionException.class);
    }

    @Test
    void getAssistedPerson_shouldThrowAssistedPersonNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(assistedPersonRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> assistedPersonService.getAssistedPerson(id))
                .isInstanceOf(AssistedPersonNotFoundException.class);
    }

    @Test
    void deleteAssistedPerson_shouldSoftDeleteAndSave_whenIdExists() {
        Long id = 3L;
        AssistedPerson entity = personBy(AUTHOR, id);

        when(assistedPersonRepository.findById(id)).thenReturn(Optional.of(entity));
        when(currentUserService.get()).thenReturn(AUTHOR);

        assistedPersonService.deleteAssistedPerson(id);

        assertThat(entity.getDeleted()).isTrue();
        verify(assistedPersonRepository).save(entity);
    }

    @Test
    void deleteAssistedPerson_shouldThrowForbidden_whenCurrentUserIsNotTheAuthor() {
        AssistedPerson entity = personBy(AUTHOR, 3L);
        when(assistedPersonRepository.findById(3L)).thenReturn(Optional.of(entity));
        when(currentUserService.get()).thenReturn(user(99L, UserRole.USER_ONG));

        assertThatThrownBy(() -> assistedPersonService.deleteAssistedPerson(3L))
                .isInstanceOf(ForbiddenActionException.class);

        assertThat(entity.getDeleted()).isFalse();
        verify(assistedPersonRepository, never()).save(any());
    }

    @Test
    void deleteAssistedPerson_shouldThrowAssistedPersonNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(assistedPersonRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> assistedPersonService.deleteAssistedPerson(id))
                .isInstanceOf(AssistedPersonNotFoundException.class);

        verify(assistedPersonRepository, never()).save(any());
    }
}

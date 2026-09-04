package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.*;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.assited_person.AssistedPersonRequestDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonResponseDTO;
import com.ajudabem.api.exceptions.AssistedPersonNotFoundException;
import com.ajudabem.api.mappers.AssistedPersonMapper;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.AssistedPersonTagRepository;
import com.ajudabem.api.repositories.TagRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
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
    private AssistedPersonTagRepository assistedPersonTagRepository;

    @Mock
    private CurrentUserService currentUserService;

    @Mock
    private TagRepository tagRepository;

    @Mock
    private AssistedPersonMapper mapper;

    @InjectMocks
    private AssistedPersonService assistedPersonService;

    private AssistedPersonRequestDTO requestDTO() {
        return new AssistedPersonRequestDTO(
                "John Doe", 30, Gender.MALE, List.of(1L, 2L), "notes",
                "street", "1", "neighborhood", "city", "state", "zip", "country"
        );
    }

    @Test
    void createAssistedPerson_shouldSetAuthorAndSaveWithTags() {
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
        when(mapper.toResponse(eq(entity), anyList())).thenReturn(expected);

        AssistedPersonResponseDTO result = assistedPersonService.createAssistedPerson(dto);

        assertThat(result).isEqualTo(expected);
        assertThat(entity.getAuthor()).isEqualTo(author);
        assertThat(entity.getRiskLevel()).isEqualTo(RiskLevel.MEDIUM);
        verify(assistedPersonRepository).save(entity);

        ArgumentCaptor<List<AssistedPersonTag>> tagsCaptor = ArgumentCaptor.forClass(List.class);
        verify(assistedPersonTagRepository).saveAll(tagsCaptor.capture());
        assertThat(tagsCaptor.getValue()).hasSize(2);
    }

    @Test
    void updateAssistedPerson_shouldReplaceTagsAndSave() {
        Long id = 5L;
        AssistedPersonRequestDTO dto = requestDTO();
        AssistedPerson entity = new AssistedPerson();
        entity.setId(id);

        Tag tag1 = new Tag();
        tag1.setId(1L);

        AssistedPersonResponseDTO expected = mock(AssistedPersonResponseDTO.class);

        when(assistedPersonRepository.findById(id)).thenReturn(Optional.of(entity));
        when(tagRepository.findAllById(dto.tagIds())).thenReturn(List.of(tag1));
        when(mapper.toResponse(eq(entity), anyList())).thenReturn(expected);

        AssistedPersonResponseDTO result = assistedPersonService.updateAssistedPerson(dto, id);

        assertThat(result).isEqualTo(expected);
        verify(mapper).updateEntity(dto, entity);
        verify(assistedPersonTagRepository).deleteByAssistedPerson(entity);
        verify(assistedPersonTagRepository).saveAll(anyList());
        verify(assistedPersonRepository).save(entity);
    }

    @Test
    void updateAssistedPerson_shouldThrowAssistedPersonNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(assistedPersonRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> assistedPersonService.updateAssistedPerson(requestDTO(), id))
                .isInstanceOf(AssistedPersonNotFoundException.class)
                .hasMessage("Assisted person is not exists");
    }

    @Test
    void getAll_shouldGroupTagsByPerson() {
        AssistedPerson person1 = new AssistedPerson();
        person1.setId(1L);
        AssistedPerson person2 = new AssistedPerson();
        person2.setId(2L);

        AssistedPersonTag tagForPerson1 = new AssistedPersonTag(person1, new Tag());

        when(assistedPersonRepository.findAll()).thenReturn(List.of(person1, person2));
        when(assistedPersonTagRepository.findAll()).thenReturn(List.of(tagForPerson1));
        when(mapper.toResponse(eq(person1), eq(List.of(tagForPerson1)))).thenReturn(mock(AssistedPersonResponseDTO.class));
        when(mapper.toResponse(eq(person2), eq(List.of()))).thenReturn(mock(AssistedPersonResponseDTO.class));

        List<AssistedPersonResponseDTO> result = assistedPersonService.getAll();

        assertThat(result).hasSize(2);
        verify(mapper).toResponse(person1, List.of(tagForPerson1));
        verify(mapper).toResponse(person2, List.of());
    }

    @Test
    void getAssistedPerson_shouldReturnMappedResponse_whenIdExists() {
        Long id = 7L;
        AssistedPerson entity = new AssistedPerson();
        entity.setId(id);
        List<AssistedPersonTag> tags = List.of(new AssistedPersonTag(entity, new Tag()));
        AssistedPersonResponseDTO expected = mock(AssistedPersonResponseDTO.class);

        when(assistedPersonRepository.findById(id)).thenReturn(Optional.of(entity));
        when(assistedPersonTagRepository.findByAssistedPerson(entity)).thenReturn(tags);
        when(mapper.toResponse(entity, tags)).thenReturn(expected);

        AssistedPersonResponseDTO result = assistedPersonService.getAssistedPerson(id);

        assertThat(result).isEqualTo(expected);
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
        AssistedPerson entity = new AssistedPerson();
        entity.setId(id);
        entity.setDeleted(false);

        when(assistedPersonRepository.findById(id)).thenReturn(Optional.of(entity));

        assistedPersonService.deleteAssistedPerson(id);

        assertThat(entity.getDeleted()).isTrue();
        verify(assistedPersonRepository).save(entity);
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

package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.assited_person.AssistedPersonTagResponseDTO;
import com.ajudabem.api.dto.assited_person.TagRequestDTO;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.TagAlreadyExistsException;
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
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TagServiceTest {

    @Mock
    private TagRepository tagRepository;

    @Mock
    private CurrentUserService currentUserService;

    @InjectMocks
    private TagService tagService;

    private static Tag tag(Long id, String name) {
        Tag tag = new Tag();
        tag.setId(id);
        tag.setName(name);
        return tag;
    }

    private static User user(UserRole role) {
        User user = new User();
        user.setRole(role);
        return user;
    }

    @Test
    void getAll_shouldReturnEveryTagByName() {
        when(tagRepository.findAllByOrderByNameAsc()).thenReturn(List.of(tag(1L, "Alimentação"), tag(2L, "Saúde")));

        List<AssistedPersonTagResponseDTO> result = tagService.getAll();

        assertThat(result).containsExactly(
                new AssistedPersonTagResponseDTO(1L, "Alimentação"),
                new AssistedPersonTagResponseDTO(2L, "Saúde"));
    }

    @Test
    void create_onlyAdminsCanAddNeeds() {
        when(currentUserService.get()).thenReturn(user(UserRole.USER_ONG));

        assertThatThrownBy(() -> tagService.create(new TagRequestDTO("Roupas")))
                .isInstanceOf(ForbiddenActionException.class);
        verify(tagRepository, never()).save(any());
    }

    @Test
    void create_rejectsADuplicatedName() {
        when(currentUserService.get()).thenReturn(user(UserRole.ADMIN));
        when(tagRepository.existsByNameIgnoreCase("Roupas")).thenReturn(true);

        assertThatThrownBy(() -> tagService.create(new TagRequestDTO(" Roupas ")))
                .isInstanceOf(TagAlreadyExistsException.class);
    }

    @Test
    void delete_isSoft() {
        Tag roupas = tag(6L, "Roupas");
        when(currentUserService.get()).thenReturn(user(UserRole.ADMIN));
        when(tagRepository.findById(6L)).thenReturn(Optional.of(roupas));

        tagService.delete(6L);

        assertThat(roupas.getDeleted()).isTrue();
        verify(tagRepository).save(roupas);
    }
}

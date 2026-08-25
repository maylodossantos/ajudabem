package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.repositories.TagRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TagServiceTest {

    @Mock
    private TagRepository tagRepository;

    @InjectMocks
    private TagService tagService;

    @Test
    void getAll_shouldReturnAllTagsFromRepository() {
        Tag tag1 = new Tag();
        tag1.setId(1L);
        tag1.setName("Alimentação");
        Tag tag2 = new Tag();
        tag2.setId(2L);
        tag2.setName("Saúde");

        when(tagRepository.findAll()).thenReturn(List.of(tag1, tag2));

        List<Tag> result = tagService.getAll();

        assertThat(result).containsExactly(tag1, tag2);
    }
}

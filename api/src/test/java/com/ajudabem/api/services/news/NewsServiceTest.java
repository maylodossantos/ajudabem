package com.ajudabem.api.services.news;

import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
import com.ajudabem.api.exceptions.NewsNotFoundException;
import com.ajudabem.api.mappers.NewsMapper;
import com.ajudabem.api.repositories.NewsRepository;
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
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NewsServiceTest {

    @Mock
    private CurrentUserService currentUserService;

    @Mock
    private NewsRepository repository;

    @Mock
    private NewsMapper mapper;

    @InjectMocks
    private NewsService newsService;

    private NewsRequestDTO requestDTO() {
        return new NewsRequestDTO("Title", "Subtitle", "Content", "cover.png");
    }

    @Test
    void createNews_shouldSetAuthorAndSave() {
        User author = new User();
        author.setId(1L);

        NewsRequestDTO dto = requestDTO();
        News entity = new News();
        NewsResponseDTO expected = mock(NewsResponseDTO.class);

        when(currentUserService.get()).thenReturn(author);
        when(mapper.toEntity(dto)).thenReturn(entity);
        when(mapper.toResponse(entity)).thenReturn(expected);

        NewsResponseDTO result = newsService.createNews(dto);

        assertThat(result).isEqualTo(expected);
        assertThat(entity.getAuthor()).isEqualTo(author);
        verify(repository).save(entity);
    }

    @Test
    void updateNews_shouldMapAndSave_whenIdExists() {
        Long id = 1L;
        News entity = new News();
        entity.setId(id);
        NewsRequestDTO dto = requestDTO();
        NewsResponseDTO expected = mock(NewsResponseDTO.class);

        when(repository.findById(id)).thenReturn(Optional.of(entity));
        when(mapper.toResponse(entity)).thenReturn(expected);

        NewsResponseDTO result = newsService.updateNews(dto, id);

        assertThat(result).isEqualTo(expected);
        verify(mapper).updateEntity(dto, entity);
        verify(repository).save(entity);
    }

    @Test
    void updateNews_shouldThrowNewsNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(repository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> newsService.updateNews(requestDTO(), id))
                .isInstanceOf(NewsNotFoundException.class)
                .hasMessage("News is not exists");

        verify(repository, never()).save(any());
    }

    @Test
    void getAll_shouldReturnMappedList() {
        News news1 = new News();
        news1.setId(1L);
        News news2 = new News();
        news2.setId(2L);
        NewsResponseDTO response1 = mock(NewsResponseDTO.class);
        NewsResponseDTO response2 = mock(NewsResponseDTO.class);

        when(repository.findAll()).thenReturn(List.of(news1, news2));
        when(mapper.toResponse(news1)).thenReturn(response1);
        when(mapper.toResponse(news2)).thenReturn(response2);

        List<NewsResponseDTO> result = newsService.getAll();

        assertThat(result).containsExactly(response1, response2);
    }

    @Test
    void getNews_shouldReturnMappedResponse_whenIdExists() {
        Long id = 1L;
        News entity = new News();
        entity.setId(id);
        NewsResponseDTO expected = mock(NewsResponseDTO.class);

        when(repository.findById(id)).thenReturn(Optional.of(entity));
        when(mapper.toResponse(entity)).thenReturn(expected);

        NewsResponseDTO result = newsService.getNews(id);

        assertThat(result).isEqualTo(expected);
    }

    @Test
    void getNews_shouldThrowNewsNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(repository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> newsService.getNews(id))
                .isInstanceOf(NewsNotFoundException.class);
    }

    @Test
    void deleteNews_shouldSoftDeleteAndSave_whenIdExists() {
        Long id = 1L;
        News entity = new News();
        entity.setId(id);
        entity.setDeleted(false);

        when(repository.findById(id)).thenReturn(Optional.of(entity));

        newsService.deleteNews(id);

        assertThat(entity.getDeleted()).isTrue();
        verify(repository).save(entity);
    }

    @Test
    void deleteNews_shouldThrowNewsNotFoundException_whenIdDoesNotExist() {
        Long id = 404L;
        when(repository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> newsService.deleteNews(id))
                .isInstanceOf(NewsNotFoundException.class);

        verify(repository, never()).save(any());
    }
}

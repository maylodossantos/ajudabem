package com.ajudabem.api.services.news;


import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.NewsNotFoundException;
import com.ajudabem.api.mappers.NewsMapper;
import com.ajudabem.api.repositories.NewsRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NewsService {

    private final CurrentUserService currentUserService;
    private final NewsRepository repository;
    private final NewsMapper mapper;

    public NewsResponseDTO createNews(NewsRequestDTO dto) {
        User user = currentUserService.get();
        requirePublisherRole(user);

        News newNews = mapper.toEntity(dto);
        newNews.setAuthor(user);

        repository.save(newNews);

        return mapper.toResponse(newNews);
    }

    public NewsResponseDTO updateNews(NewsRequestDTO dto, Long id) {
        requirePublisherRole(currentUserService.get());

        News news = findNews(id);

        mapper.updateEntity(dto, news);

        repository.save(news);

        return mapper.toResponse(news);
    }

    public List<NewsResponseDTO> getAll() {
        List<News> newsList = repository.findAll();

        return newsList.stream()
                .map(mapper::toResponse)
                .toList();
    }

    public NewsResponseDTO getNews(Long id) {
        News news = findNews(id);

        return mapper.toResponse(news);
    }

    public void deleteNews(Long id) {
        requirePublisherRole(currentUserService.get());

        News news = findNews(id);

        news.softDelete();
        repository.save(news);
    }

    private void requirePublisherRole(User user) {
        if (user.getRole() != UserRole.ADMIN) {
            throw new ForbiddenActionException("Only admins can publish news");
        }
    }

    private News findNews(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new NewsNotFoundException("News not found"));
    }
}

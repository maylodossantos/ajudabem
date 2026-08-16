package com.ajudabem.api.services.news;


import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
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

        News newNews = mapper.toEntity(dto);
        newNews.setAuthor(user);

        repository.save(newNews);

        return mapper.toResponse(newNews);
    }

    public NewsResponseDTO updateNews(NewsRequestDTO dto, Long id) {

        News news = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("News is not exists"));

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
        News news = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("News is not exists"));

        return mapper.toResponse(news);
    }

}

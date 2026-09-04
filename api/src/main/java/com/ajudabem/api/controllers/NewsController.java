package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
import com.ajudabem.api.services.news.NewsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/news")
public class NewsController {

    private final NewsService newsService;

    @PostMapping
    public ResponseEntity<NewsResponseDTO> createNews(@Valid @RequestBody NewsRequestDTO body) {
        return ResponseEntity.ok(newsService.createNews(body));
    }

    @PutMapping("/{id}")
    public ResponseEntity<NewsResponseDTO> updateNews(@Valid @RequestBody NewsRequestDTO body, @PathVariable Long id) {
        return ResponseEntity.ok(newsService.updateNews(body, id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNews(@PathVariable Long id) {
        newsService.deleteNews(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<List<NewsResponseDTO>> getAllNews() {
        return ResponseEntity.ok(newsService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<NewsResponseDTO> getNewsById(@PathVariable Long id) {
        return  ResponseEntity.ok(newsService.getNews(id));
    }


}

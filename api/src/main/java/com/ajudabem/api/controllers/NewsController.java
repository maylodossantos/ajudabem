package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.news.NewsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/news")
@Tag(name = "News")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class NewsController {

    private final NewsService newsService;

    @Operation(summary = "Create News")
    @PostMapping
    public ResponseEntity<NewsResponseDTO> createNews(@Valid @RequestBody NewsRequestDTO body) {
        return ResponseEntity.ok(newsService.createNews(body));
    }

    @Operation(summary = "Edit News")
    @PutMapping("/{id}")
    public ResponseEntity<NewsResponseDTO> updateNews(@Valid @RequestBody NewsRequestDTO body, @PathVariable Long id) {
        return ResponseEntity.ok(newsService.updateNews(body, id));
    }

    @Operation(summary = "Delete News")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNews(@PathVariable Long id) {
        newsService.deleteNews(id);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get All News")
    @GetMapping
    public ResponseEntity<List<NewsResponseDTO>> getAllNews() {
        return ResponseEntity.ok(newsService.getAll());
    }

    @Operation(summary = "Get News By Id")
    @GetMapping("/{id}")
    public ResponseEntity<NewsResponseDTO> getNewsById(@PathVariable Long id) {
        return  ResponseEntity.ok(newsService.getNews(id));
    }

}

package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.services.assisted_person.TagService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/tag")
@io.swagger.v3.oas.annotations.tags.Tag(name = "Tag")
@io.swagger.v3.oas.annotations.security.SecurityRequirement(name = com.ajudabem.api.infra.OpenApiConfig.BEARER_SCHEME_NAME)
public class TagsController {

    private final TagService tagService;

    @Operation(summary = "Get All Tags")
    @GetMapping
    public ResponseEntity<List<Tag>> getAllTags() {
        return ResponseEntity.ok(tagService.getAll());
    }

}

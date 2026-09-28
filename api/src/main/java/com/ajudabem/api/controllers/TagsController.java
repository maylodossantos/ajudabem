package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.assited_person.AssistedPersonTagResponseDTO;
import com.ajudabem.api.dto.assited_person.TagRequestDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.assisted_person.TagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/tag")
@io.swagger.v3.oas.annotations.tags.Tag(name = "Tag")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class TagsController {

    private final TagService tagService;

    @Operation(summary = "Every need (tag)")
    @GetMapping
    public ResponseEntity<List<AssistedPersonTagResponseDTO>> getAllTags() {
        return ResponseEntity.ok(tagService.getAll());
    }

    @Operation(summary = "Create a need (admins)")
    @PostMapping
    public ResponseEntity<AssistedPersonTagResponseDTO> create(@Valid @RequestBody TagRequestDTO body) {
        return ResponseEntity.ok(tagService.create(body));
    }

    @Operation(summary = "Rename a need (admins)")
    @PutMapping("/{id}")
    public ResponseEntity<AssistedPersonTagResponseDTO> update(
            @PathVariable Long id, @Valid @RequestBody TagRequestDTO body) {
        return ResponseEntity.ok(tagService.update(id, body));
    }

    @Operation(summary = "Delete a need (admins)")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        tagService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.help_point.HelpPointRequestDTO;
import com.ajudabem.api.dto.help_point.HelpPointResponseDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.help_point.HelpPointService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
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
@RequestMapping("/help-point")
@Tag(name = "Help Points")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class HelpPointController {

    private final HelpPointService helpPointService;

    @Operation(summary = "List help points (public)")
    @GetMapping
    public ResponseEntity<List<HelpPointResponseDTO>> getAll() {
        return ResponseEntity.ok(helpPointService.getAll());
    }

    @Operation(summary = "Get a help point (public)")
    @GetMapping("/{id}")
    public ResponseEntity<HelpPointResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(helpPointService.get(id));
    }

    @Operation(summary = "Create a help point (admin)")
    @PostMapping
    public ResponseEntity<HelpPointResponseDTO> create(@Valid @RequestBody HelpPointRequestDTO body) {
        return ResponseEntity.ok(helpPointService.create(body));
    }

    @Operation(summary = "Edit a help point (admin)")
    @PutMapping("/{id}")
    public ResponseEntity<HelpPointResponseDTO> update(@PathVariable Long id, @Valid @RequestBody HelpPointRequestDTO body) {
        return ResponseEntity.ok(helpPointService.update(id, body));
    }

    @Operation(summary = "Delete a help point (admin)")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        helpPointService.delete(id);
        return ResponseEntity.ok().build();
    }
}

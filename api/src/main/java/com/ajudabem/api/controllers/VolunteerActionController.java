package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.initiative.VolunteerActionRequestDTO;
import com.ajudabem.api.dto.initiative.VolunteerActionResponseDTO;
import com.ajudabem.api.dto.initiative.VolunteerApplicationResponseDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.initiative.VolunteerActionService;
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
@RequestMapping("/volunteer-action")
@Tag(name = "Volunteer actions")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class VolunteerActionController {

    private final VolunteerActionService actionService;

    @Operation(summary = "Upcoming actions open for volunteers")
    @GetMapping
    public ResponseEntity<List<VolunteerActionResponseDTO>> open() {
        return ResponseEntity.ok(actionService.open());
    }

    @Operation(summary = "Actions of my organization")
    @GetMapping("/mine")
    public ResponseEntity<List<VolunteerActionResponseDTO>> mine() {
        return ResponseEntity.ok(actionService.mine());
    }

    @Operation(summary = "An action, with my application status")
    @GetMapping("/{id}")
    public ResponseEntity<VolunteerActionResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(actionService.get(id));
    }

    @Operation(summary = "Create an action (approved organizations)")
    @PostMapping
    public ResponseEntity<VolunteerActionResponseDTO> create(@Valid @RequestBody VolunteerActionRequestDTO body) {
        return ResponseEntity.ok(actionService.create(body));
    }

    @Operation(summary = "Update an action (its organization)")
    @PutMapping("/{id}")
    public ResponseEntity<VolunteerActionResponseDTO> update(
            @PathVariable Long id, @Valid @RequestBody VolunteerActionRequestDTO body) {
        return ResponseEntity.ok(actionService.update(id, body));
    }

    @Operation(summary = "Finish an action (its organization)")
    @PostMapping("/{id}/finish")
    public ResponseEntity<VolunteerActionResponseDTO> finish(@PathVariable Long id) {
        return ResponseEntity.ok(actionService.finish(id));
    }

    @Operation(summary = "Apply as a volunteer")
    @PostMapping("/{id}/apply")
    public ResponseEntity<VolunteerActionResponseDTO> apply(@PathVariable Long id) {
        return ResponseEntity.ok(actionService.apply(id));
    }

    @Operation(summary = "Withdraw my application")
    @DeleteMapping("/{id}/apply")
    public ResponseEntity<VolunteerActionResponseDTO> withdraw(@PathVariable Long id) {
        return ResponseEntity.ok(actionService.withdraw(id));
    }

    @Operation(summary = "Volunteers who applied (its organization)")
    @GetMapping("/{id}/volunteers")
    public ResponseEntity<List<VolunteerApplicationResponseDTO>> volunteers(@PathVariable Long id) {
        return ResponseEntity.ok(actionService.volunteers(id));
    }

    @Operation(summary = "Accept a volunteer (its organization)")
    @PostMapping("/{id}/volunteers/{applicationId}/accept")
    public ResponseEntity<VolunteerApplicationResponseDTO> accept(
            @PathVariable Long id, @PathVariable Long applicationId) {
        return ResponseEntity.ok(actionService.accept(id, applicationId));
    }
}

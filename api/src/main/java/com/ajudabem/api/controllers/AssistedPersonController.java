package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.assited_person.AssistedPersonRequestDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonResponseDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.assisted_person.AssistedPersonService;
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
@RequestMapping("/assisted-person")
@Tag(name = "Assisted Person")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class AssistedPersonController {

    private final AssistedPersonService assistedPersonService;

    @Operation(summary = "Create Assisted Person")
    @PostMapping
    public ResponseEntity<AssistedPersonResponseDTO> createAssistedPerson(@Valid @RequestBody AssistedPersonRequestDTO body) {
        return ResponseEntity.ok(assistedPersonService.createAssistedPerson(body));
    }

    @Operation(summary = "Edit Assisted Person")
    @PutMapping("/{id}")
    public ResponseEntity<AssistedPersonResponseDTO> updateAssistedPerson(@Valid @RequestBody AssistedPersonRequestDTO body, @PathVariable Long id) {
        return ResponseEntity.ok(assistedPersonService.updateAssistedPerson(body, id));
    }

    @Operation(summary = "Delete Assisted Person")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAssistedPerson(@PathVariable Long id) {
        assistedPersonService.deleteAssistedPerson(id);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get the Assisted People registered by the current user")
    @GetMapping
    public ResponseEntity<List<AssistedPersonResponseDTO>> getAllAssistedPerson() {
        return ResponseEntity.ok(assistedPersonService.getAllFromCurrentUser());
    }

    @Operation(summary = "Get Assisted Person By Id")
    @GetMapping("/{id}")
    public ResponseEntity<AssistedPersonResponseDTO> getAssistedPersonById(@PathVariable Long id) {
        return  ResponseEntity.ok(assistedPersonService.getAssistedPerson(id));
    }
}

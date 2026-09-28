package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.care.CareCaseDetailResponseDTO;
import com.ajudabem.api.dto.care.CareCaseResponseDTO;
import com.ajudabem.api.dto.care.CareRecordRequestDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.care.CareService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/care")
@Tag(name = "Care")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class CareController {

    private final CareService careService;

    @Operation(summary = "People nominated and waiting for an organization (organizations and admins)")
    @GetMapping("/nominated")
    public ResponseEntity<List<CareCaseResponseDTO>> nominated() {
        return ResponseEntity.ok(careService.nominated());
    }

    @Operation(summary = "Located people nominated or in care, for the map (organizations and admins)")
    @GetMapping("/map")
    public ResponseEntity<List<CareCaseResponseDTO>> map() {
        return ResponseEntity.ok(careService.map());
    }

    @Operation(summary = "Cases of my organization (every case for admins)")
    @GetMapping("/cases")
    public ResponseEntity<List<CareCaseResponseDTO>> myCases() {
        return ResponseEntity.ok(careService.myCases());
    }

    @Operation(summary = "A case with its care records")
    @GetMapping("/{personId}")
    public ResponseEntity<CareCaseDetailResponseDTO> get(@PathVariable Long personId) {
        return ResponseEntity.ok(careService.get(personId));
    }

    @Operation(summary = "Take care of a nominated person (approved organizations)")
    @PostMapping("/{personId}/assume")
    public ResponseEntity<CareCaseResponseDTO> assume(@PathVariable Long personId) {
        return ResponseEntity.ok(careService.assume(personId));
    }

    @Operation(summary = "Add a care record (organization in charge)")
    @PostMapping("/{personId}/records")
    public ResponseEntity<CareCaseDetailResponseDTO> addRecord(
            @PathVariable Long personId, @Valid @RequestBody CareRecordRequestDTO body) {
        return ResponseEntity.ok(careService.addRecord(personId, body));
    }
}

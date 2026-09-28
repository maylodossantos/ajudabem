package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.initiative.CampaignRequestDTO;
import com.ajudabem.api.dto.initiative.CampaignResponseDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.initiative.CampaignService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
@RequestMapping("/campaign")
@Tag(name = "Campaigns")
public class CampaignController {

    private final CampaignService campaignService;

    @Operation(summary = "Active campaigns (public)")
    @GetMapping
    public ResponseEntity<List<CampaignResponseDTO>> active() {
        return ResponseEntity.ok(campaignService.active());
    }

    @Operation(summary = "Campaigns of my organization", security = @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME))
    @GetMapping("/mine")
    public ResponseEntity<List<CampaignResponseDTO>> mine() {
        return ResponseEntity.ok(campaignService.mine());
    }

    @Operation(summary = "A campaign (public)")
    @GetMapping("/{id}")
    public ResponseEntity<CampaignResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(campaignService.get(id));
    }

    @Operation(summary = "Create a campaign (approved organizations)", security = @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME))
    @PostMapping
    public ResponseEntity<CampaignResponseDTO> create(@Valid @RequestBody CampaignRequestDTO body) {
        return ResponseEntity.ok(campaignService.create(body));
    }

    @Operation(summary = "Update a campaign (its organization)", security = @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME))
    @PutMapping("/{id}")
    public ResponseEntity<CampaignResponseDTO> update(@PathVariable Long id, @Valid @RequestBody CampaignRequestDTO body) {
        return ResponseEntity.ok(campaignService.update(id, body));
    }

    @Operation(summary = "Finish a campaign (its organization)", security = @SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME))
    @PostMapping("/{id}/finish")
    public ResponseEntity<CampaignResponseDTO> finish(@PathVariable Long id) {
        return ResponseEntity.ok(campaignService.finish(id));
    }
}

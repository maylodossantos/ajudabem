package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.impact.OrganizationImpactDTO;
import com.ajudabem.api.dto.impact.PlatformImpactDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.impact.ImpactService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/impact")
@Tag(name = "Impact")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class ImpactController {

    private final ImpactService impactService;

    @Operation(summary = "Numbers of the whole platform")
    @GetMapping
    public ResponseEntity<PlatformImpactDTO> platform() {
        return ResponseEntity.ok(impactService.platform());
    }

    @Operation(summary = "Numbers of my organization")
    @GetMapping("/organization")
    public ResponseEntity<OrganizationImpactDTO> organization() {
        return ResponseEntity.ok(impactService.organization());
    }
}

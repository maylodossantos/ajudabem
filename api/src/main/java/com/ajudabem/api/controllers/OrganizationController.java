package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.organization.OrganizationDocumentType;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.dto.organization.DocumentFileDTO;
import com.ajudabem.api.dto.organization.OrganizationRequestDTO;
import com.ajudabem.api.dto.organization.OrganizationResponseDTO;
import com.ajudabem.api.dto.organization.RejectOrganizationRequestDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.organization.OrganizationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/organization")
@Tag(name = "Organizations")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class OrganizationController {

    private final OrganizationService organizationService;

    @Operation(summary = "My organization validation request")
    @GetMapping("/me")
    public ResponseEntity<OrganizationResponseDTO> getMine() {
        return ResponseEntity.ok(organizationService.getMine());
    }

    @Operation(summary = "Request (or request again) the validation of my organization")
    @PostMapping(value = "/me", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<OrganizationResponseDTO> submit(
            @Valid @RequestPart("data") OrganizationRequestDTO body,
            @RequestParam Map<String, MultipartFile> parts) {
        Map<OrganizationDocumentType, MultipartFile> documents = new EnumMap<>(OrganizationDocumentType.class);
        for (OrganizationDocumentType type : OrganizationDocumentType.values()) {
            if (parts.containsKey(type.name())) {
                documents.put(type, parts.get(type.name()));
            }
        }
        return ResponseEntity.ok(organizationService.submit(body, documents));
    }

    @Operation(summary = "List validation requests (admin)")
    @GetMapping
    public ResponseEntity<List<OrganizationResponseDTO>> list(
            @RequestParam(required = false) OrganizationStatus status,
            @RequestParam(required = false) String search) {
        return ResponseEntity.ok(organizationService.list(status, search));
    }

    @Operation(summary = "Get a validation request (admin or owner)")
    @GetMapping("/{id}")
    public ResponseEntity<OrganizationResponseDTO> get(@PathVariable Long id) {
        return ResponseEntity.ok(organizationService.get(id));
    }

    @Operation(summary = "Download a document PDF (admin or owner)")
    @GetMapping("/{id}/documents/{type}")
    public ResponseEntity<byte[]> getDocument(@PathVariable Long id, @PathVariable OrganizationDocumentType type) {
        DocumentFileDTO document = organizationService.getDocument(id, type);

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(document.contentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.inline()
                        .filename(document.fileName(), StandardCharsets.UTF_8)
                        .build()
                        .toString())
                .header(HttpHeaders.CACHE_CONTROL, "private, no-store")
                .body(document.content());
    }

    @Operation(summary = "Approve a validation request (admin)")
    @PostMapping("/{id}/approve")
    public ResponseEntity<OrganizationResponseDTO> approve(@PathVariable Long id) {
        return ResponseEntity.ok(organizationService.approve(id));
    }

    @Operation(summary = "Reject a validation request (admin)")
    @PostMapping("/{id}/reject")
    public ResponseEntity<OrganizationResponseDTO> reject(
            @PathVariable Long id, @Valid @RequestBody RejectOrganizationRequestDTO body) {
        return ResponseEntity.ok(organizationService.reject(id, body));
    }
}

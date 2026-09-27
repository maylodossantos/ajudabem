package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.user.UpdateUserRequestDTO;
import com.ajudabem.api.dto.user.UserResponseDTO;
import com.ajudabem.api.infra.OpenApiConfig;
import com.ajudabem.api.services.user.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/user")
@Tag(name = "Users")
@SecurityRequirement(name = OpenApiConfig.BEARER_SCHEME_NAME)
public class UserController {

    private final UserService userService;

    @Operation(summary = "Auth info")
    @GetMapping("/me")
    public ResponseEntity<UserResponseDTO> getMe() {
        return ResponseEntity.ok(userService.getCurrentUser());
    }

    @Operation(summary = "Edit Profile")
    @PutMapping("/me")
    public ResponseEntity<UserResponseDTO> updateMe(@Valid @RequestBody UpdateUserRequestDTO body) {
        return ResponseEntity.ok(userService.updateCurrentUser(body));
    }

    @Operation(summary = "Delete Account")
    @DeleteMapping("/me")
    public ResponseEntity<Void> deleteMe() {
        userService.deleteMe();
        return ResponseEntity.ok().build();
    }
}

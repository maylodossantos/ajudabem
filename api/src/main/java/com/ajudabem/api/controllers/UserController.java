package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.user.UpdateUserRequestDTO;
import com.ajudabem.api.dto.user.UserResponseDTO;
import com.ajudabem.api.services.user.UserService;
import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/user")
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponseDTO> getMe() {
        return ResponseEntity.ok(userService.getCurrentUser());
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponseDTO> updateMe(@Valid @RequestBody UpdateUserRequestDTO body) {
        return ResponseEntity.ok(userService.updateCurrentUser(body));
    }

    @DeleteMapping("/me")
    public ResponseEntity<Void> deleteMe() {
        userService.deleteMe();
        return ResponseEntity.ok().build();
    }
}

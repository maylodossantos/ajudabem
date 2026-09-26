package com.ajudabem.api.controllers;

import com.ajudabem.api.dto.auth.ForgotPasswordRequestDTO;
import com.ajudabem.api.dto.auth.LoginRequestDTO;
import com.ajudabem.api.dto.auth.RegisterRequestDTO;
import com.ajudabem.api.dto.auth.ResetPasswordRequestDTO;
import com.ajudabem.api.dto.auth.ResponseDTO;
import com.ajudabem.api.dto.auth.VerifyCodeRequestDTO;
import com.ajudabem.api.dto.auth.VerifyCodeResponseDTO;
import com.ajudabem.api.services.user.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
@Tag(name = "Auth")
public class AuthController {

    private final UserService userService;

    @Operation(summary = "Login")
    @PostMapping("/login")
    public ResponseEntity<ResponseDTO> login(@Valid @RequestBody LoginRequestDTO body) {
            return ResponseEntity.ok(userService.login(body));
    }

    @Operation(summary = "Register")
    @PostMapping("/register")
    public ResponseEntity<ResponseDTO> register(@Valid @RequestBody RegisterRequestDTO body) {
        return ResponseEntity.ok(userService.register(body));
    }

    @Operation(summary = "Forgot Password")
    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@Valid @RequestBody ForgotPasswordRequestDTO body) {
        userService.forgotPassword(body);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Verify Code")
    @PostMapping("/verify-code")
    public ResponseEntity<VerifyCodeResponseDTO> verifyCode(@Valid @RequestBody VerifyCodeRequestDTO body) {
        return ResponseEntity.ok(userService.verifyCode(body));
    }

    @Operation(summary = "Reset Password")
    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(@Valid @RequestBody ResetPasswordRequestDTO body) {
        userService.resetPassword(body);
        return ResponseEntity.ok().build();
    }
}

package com.ajudabem.api.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record ForgotPasswordRequestDTO (
        @NotBlank(message = "Email é obrigatório")
        @Email(message = "Email inválido")
        String email
) { }

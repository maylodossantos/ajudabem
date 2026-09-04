package com.ajudabem.api.dto.user;

import jakarta.validation.constraints.Size;

public record UpdateUserRequestDTO (
        @Size(max = 100, message = "Nome deve ter no máximo 100 caracteres")
        String name,

        String phone,

        String profileImage
) { }

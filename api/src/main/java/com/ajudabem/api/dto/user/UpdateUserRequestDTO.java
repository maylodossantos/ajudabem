package com.ajudabem.api.dto.user;

import com.ajudabem.api.infra.validation.ValidCpf;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record UpdateUserRequestDTO (
        @Size(max = 100, message = "Nome deve ter no máximo 100 caracteres")
        String name,

        String phone,

        String profileImage,

        @ValidCpf
        String cpf,

        @Past(message = "Data de nascimento deve estar no passado")
        LocalDate birthDate
) { }

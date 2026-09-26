package com.ajudabem.api.dto.auth;

import com.ajudabem.api.infra.validation.ValidCpf;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record RegisterRequestDTO (
        @NotBlank(message = "Nome é obrigatório")
        @Size(max = 100, message = "Nome deve ter no máximo 100 caracteres")
        String name,

        @NotBlank(message = "Email é obrigatório")
        @Email(message = "Email inválido")
        String email,

        @NotBlank(message = "Telefone é obrigatório")
        String phone,

        @NotBlank(message = "CPF é obrigatório")
        @ValidCpf
        String cpf,

        @NotNull(message = "Data de nascimento é obrigatória")
        @Past(message = "Data de nascimento deve estar no passado")
        LocalDate birthDate,

        @NotBlank(message = "Senha é obrigatória")
        @Size(min = 6, message = "Senha deve ter no mínimo 6 caracteres")
        String password,

        @NotNull(message = "É necessário aceitar os Termos de Uso e a Política de Privacidade")
        @AssertTrue(message = "É necessário aceitar os Termos de Uso e a Política de Privacidade")
        Boolean acceptedTerms
) { }

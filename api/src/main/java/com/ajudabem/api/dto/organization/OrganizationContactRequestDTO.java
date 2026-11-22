package com.ajudabem.api.dto.organization;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record OrganizationContactRequestDTO(
        @NotBlank(message = "Endereço é obrigatório")
        @Size(max = 255, message = "Endereço deve ter no máximo 255 caracteres")
        String street,

        @NotBlank(message = "Número é obrigatório")
        @Size(max = 20, message = "Número deve ter no máximo 20 caracteres")
        String number,

        @Size(max = 100, message = "Bairro deve ter no máximo 100 caracteres")
        String neighborhood,

        @NotBlank(message = "Cidade é obrigatória")
        @Size(max = 100, message = "Cidade deve ter no máximo 100 caracteres")
        String city,

        @NotBlank(message = "Estado é obrigatório")
        @Pattern(regexp = "[A-Za-z]{2}", message = "Estado deve ser a sigla da UF")
        String state,

        @NotBlank(message = "CEP é obrigatório")
        @Pattern(regexp = "\\d{5}-?\\d{3}", message = "CEP inválido")
        String zipCode,

        @Size(max = 255, message = "Site deve ter no máximo 255 caracteres")
        String website,

        @Size(max = 100, message = "Instagram deve ter no máximo 100 caracteres")
        String instagram
) { }

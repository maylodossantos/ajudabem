package com.ajudabem.api.dto.assited_person;

import com.ajudabem.api.domains.assisted_person.Gender;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record AssistedPersonRequestDTO (
        @NotBlank(message = "Nome é obrigatório")
        @Size(max = 100, message = "Nome deve ter no máximo 100 caracteres")
        String full_name,

        @NotNull(message = "Idade é obrigatória")
        @Min(value = 0, message = "Idade não pode ser negativa")
        Integer age,

        @NotNull(message = "Gênero é obrigatório")
        Gender gender,

        List<Long> tagIds,
        String notes,
        String street,
        String number,
        String neighborhood,
        String city,
        String state,
        String zip_code,
        String country
) { }

package com.ajudabem.api.dto.assited_person;

import com.ajudabem.api.domains.assisted_person.Gender;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

import java.util.List;

public record AssistedPersonRequestDTO (
        @Size(max = 100, message = "Nome deve ter no máximo 100 caracteres")
        String full_name,

        @Min(value = 0, message = "Idade não pode ser negativa")
        Integer age,

        Gender gender,

        Boolean identified,

        List<Long> tagIds,
        String notes,
        String street,
        String number,
        String neighborhood,
        String city,
        String state,
        String zip_code,
        String country,

        @Size(max = 500, message = "Descrição do local deve ter no máximo 500 caracteres")
        String locationDescription
) {

    public static final String UNIDENTIFIED_NAME = "Pessoa não identificada";

    @JsonIgnore
    public boolean isUnidentified() {
        return Boolean.FALSE.equals(identified);
    }

    @JsonIgnore
    @AssertTrue(message = "Informe nome, idade e gênero da pessoa")
    public boolean isIdentityGiven() {
        return isUnidentified()
                || (full_name != null && !full_name.isBlank() && age != null && gender != null);
    }
}

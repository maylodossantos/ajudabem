package com.ajudabem.api.dto.initiative;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.time.LocalTime;

public record VolunteerActionRequestDTO(
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 150, message = "Título deve ter no máximo 150 caracteres")
        String title,

        @NotNull(message = "Data é obrigatória")
        @FutureOrPresent(message = "A data não pode estar no passado")
        LocalDate date,

        @NotNull(message = "Horário de início é obrigatório")
        LocalTime startTime,

        @NotNull(message = "Horário de término é obrigatório")
        LocalTime endTime,

        @NotNull(message = "Quantidade de voluntários é obrigatória")
        @Min(value = 1, message = "Informe pelo menos 1 voluntário")
        @Max(value = 1000, message = "Quantidade de voluntários muito alta")
        Integer volunteersNeeded,

        @NotBlank(message = "Endereço é obrigatório")
        @Size(max = 255, message = "Endereço deve ter no máximo 255 caracteres")
        String street,

        @Size(max = 20, message = "Número deve ter no máximo 20 caracteres")
        String number,

        @NotBlank(message = "Cidade é obrigatória")
        @Size(max = 100, message = "Cidade deve ter no máximo 100 caracteres")
        String city,

        @NotBlank(message = "Estado é obrigatório")
        @Size(min = 2, max = 2, message = "Use a sigla do estado")
        String state,

        @Size(max = 9, message = "CEP inválido")
        String zipCode,

        @NotBlank(message = "Descrição é obrigatória")
        @Size(max = 2000, message = "Descrição deve ter no máximo 2000 caracteres")
        String description,

        @Size(max = 2000, message = "Afazeres deve ter no máximo 2000 caracteres")
        String tasks,

        @Size(max = 2000, message = "Requisitos deve ter no máximo 2000 caracteres")
        String requirements,

        @Size(max = 2000, message = "Observações deve ter no máximo 2000 caracteres")
        String notes
) {

    @JsonIgnore
    @AssertTrue(message = "O término deve ser depois do início")
    public boolean isTimeRangeValid() {
        return startTime == null || endTime == null || endTime.isAfter(startTime);
    }
}

package com.ajudabem.api.dto.help_point;

import jakarta.validation.constraints.NotNull;

import java.time.DayOfWeek;
import java.time.LocalTime;

public record OpeningHoursDTO(
        @NotNull(message = "Dia da semana é obrigatório")
        DayOfWeek dayOfWeek,

        @NotNull(message = "Horário de abertura é obrigatório")
        LocalTime opensAt,

        @NotNull(message = "Horário de fechamento é obrigatório")
        LocalTime closesAt
) { }

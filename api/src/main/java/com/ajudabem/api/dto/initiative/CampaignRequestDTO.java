package com.ajudabem.api.dto.initiative;

import com.ajudabem.api.domains.initiative.CampaignCategory;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;

public record CampaignRequestDTO(
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 150, message = "Título deve ter no máximo 150 caracteres")
        String title,

        @Size(max = 2000, message = "Doações deve ter no máximo 2000 caracteres")
        String donationInfo,

        @Size(max = 300, message = "Título auxiliar deve ter no máximo 300 caracteres")
        String subtitle,

        @NotBlank(message = "Descrição é obrigatória")
        @Size(max = 5000, message = "Descrição deve ter no máximo 5000 caracteres")
        String description,

        @NotNull(message = "Categoria é obrigatória")
        CampaignCategory category,

        @PositiveOrZero(message = "A meta não pode ser negativa")
        @DecimalMax(value = "9999999999.99", message = "Meta muito alta")
        BigDecimal goalAmount,

        @FutureOrPresent(message = "O prazo não pode estar no passado")
        LocalDate deadline,

        @Size(max = 500, message = "Imagem inválida")
        String coverImage
) { }

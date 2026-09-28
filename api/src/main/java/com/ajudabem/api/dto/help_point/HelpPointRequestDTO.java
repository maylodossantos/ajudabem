package com.ajudabem.api.dto.help_point;

import com.ajudabem.api.domains.help_point.AssistanceType;
import com.ajudabem.api.domains.help_point.HelpPointOrganizationType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.Set;

public record HelpPointRequestDTO(
        @NotBlank(message = "Nome é obrigatório")
        @Size(max = 150, message = "Nome deve ter no máximo 150 caracteres")
        String name,

        @Size(max = 1000, message = "Descrição deve ter no máximo 1000 caracteres")
        String description,

        @Size(max = 500, message = "Endereço da imagem deve ter no máximo 500 caracteres")
        String coverImage,

        @NotNull(message = "Tipo de organização é obrigatório")
        HelpPointOrganizationType organizationType,

        @NotEmpty(message = "Selecione ao menos um serviço oferecido")
        Set<AssistanceType> services,

        @NotBlank(message = "Endereço é obrigatório")
        @Size(max = 255, message = "Endereço deve ter no máximo 255 caracteres")
        String street,

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

        @Pattern(regexp = "(\\d{5}-?\\d{3})?", message = "CEP inválido")
        String zipCode,

        @Size(max = 20, message = "Telefone deve ter no máximo 20 caracteres")
        String phone,

        @Size(max = 20, message = "WhatsApp deve ter no máximo 20 caracteres")
        String whatsapp,

        @Email(message = "E-mail inválido")
        @Size(max = 255, message = "E-mail deve ter no máximo 255 caracteres")
        String email,

        @Size(max = 255, message = "Responsável deve ter no máximo 255 caracteres")
        String responsible,

        List<@Valid OpeningHoursDTO> openingHours,

        @Size(max = 255, message = "Observação do horário deve ter no máximo 255 caracteres")
        String scheduleNote,

        @Size(max = 1000, message = "Observações devem ter no máximo 1000 caracteres")
        String notes
) { }

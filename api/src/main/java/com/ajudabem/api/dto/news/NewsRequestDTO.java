package com.ajudabem.api.dto.news;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record NewsRequestDTO(
        @NotBlank(message = "Título é obrigatório")
        @Size(max = 150, message = "Título deve ter no máximo 150 caracteres")
        String title,

        @Size(max = 200, message = "Subtítulo deve ter no máximo 200 caracteres")
        String subtitle,

        @NotBlank(message = "Conteúdo é obrigatório")
        String content,

        String cover_image
) { }

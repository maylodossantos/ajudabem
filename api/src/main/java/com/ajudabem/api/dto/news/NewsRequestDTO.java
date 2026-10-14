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
        @Size(max = 10000, message = "Conteúdo deve ter no máximo 10000 caracteres")
        String content,

        @Size(max = 500, message = "Imagem inválida")
        String cover_image,

        @Size(max = 100, message = "Cidade deve ter no máximo 100 caracteres")
        String city,

        @Size(max = 2, message = "Use a sigla do estado")
        String state
) { }

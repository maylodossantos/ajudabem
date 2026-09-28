package com.ajudabem.api.dto.organization;

import com.ajudabem.api.domains.organization.RejectionReason;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RejectOrganizationRequestDTO(
        @NotNull(message = "Motivo é obrigatório")
        RejectionReason reason,

        @Size(max = 1000, message = "Observação deve ter no máximo 1000 caracteres")
        String note
) { }

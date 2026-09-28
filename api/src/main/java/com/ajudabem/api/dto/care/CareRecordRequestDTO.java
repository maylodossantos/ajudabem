package com.ajudabem.api.dto.care;

import com.ajudabem.api.domains.care.CareRecordStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.List;

public record CareRecordRequestDTO(
        @NotNull(message = "Status é obrigatório")
        CareRecordStatus status,

        @NotNull(message = "Data e horário são obrigatórios")
        @PastOrPresent(message = "O atendimento não pode estar no futuro")
        LocalDateTime occurredAt,

        List<Long> tagIds,

        @Size(max = 2000, message = "Situação deve ter no máximo 2000 caracteres")
        String situation,

        @Size(max = 2000, message = "Ação realizada deve ter no máximo 2000 caracteres")
        String actionTaken,

        @Size(max = 2000, message = "Encaminhamento deve ter no máximo 2000 caracteres")
        String referral,

        @Size(max = 2000, message = "Próxima ação deve ter no máximo 2000 caracteres")
        String nextStep,

        @Size(max = 2000, message = "Resumo deve ter no máximo 2000 caracteres")
        String summary,

        @Size(max = 2000, message = "Observação deve ter no máximo 2000 caracteres")
        String note,

        FinishReason finishReason
) {

    @JsonIgnore
    @AssertTrue(message = "Informe o motivo da finalização")
    public boolean isFinishReasonGiven() {
        return status != CareRecordStatus.FINISHED || finishReason != null;
    }
}

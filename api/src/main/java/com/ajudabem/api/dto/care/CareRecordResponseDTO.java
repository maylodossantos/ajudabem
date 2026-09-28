package com.ajudabem.api.dto.care;

import com.ajudabem.api.domains.care.CareRecordStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.ajudabem.api.dto.user.UserResponseSummaryDTO;

import java.time.LocalDateTime;

public record CareRecordResponseDTO(
        Long id,
        Integer number,
        CareRecordStatus status,
        LocalDateTime occurredAt,
        String situation,
        String actionTaken,
        String referral,
        String nextStep,
        String summary,
        String note,
        FinishReason finishReason,
        UserResponseSummaryDTO author
) { }

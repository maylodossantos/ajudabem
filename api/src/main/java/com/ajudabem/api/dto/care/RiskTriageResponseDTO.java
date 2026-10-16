package com.ajudabem.api.dto.care;

import com.ajudabem.api.domains.assisted_person.RiskLevel;

import java.time.LocalDateTime;

public record RiskTriageResponseDTO(RiskLevel riskLevel, String justification, String model,
                                    LocalDateTime createdAt) { }

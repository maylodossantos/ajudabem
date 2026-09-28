package com.ajudabem.api.dto.assited_person;

import com.ajudabem.api.domains.assisted_person.Gender;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.care.CareStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.ajudabem.api.dto.organization.OrganizationSummaryDTO;
import com.ajudabem.api.dto.user.UserResponseSummaryDTO;

import java.time.LocalDateTime;
import java.util.List;

public record AssistedPersonResponseDTO(Long id, String full_name, Integer age, Gender gender, RiskLevel riskLevel, List<AssistedPersonTagResponseDTO> tags, UserResponseSummaryDTO author, String notes, String street, String number, String neighborhood, String city, String state, String zip_code, String country, CareStatus careStatus, FinishReason finishReason, OrganizationSummaryDTO organization, LocalDateTime careUpdatedAt) { }
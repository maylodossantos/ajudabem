package com.ajudabem.api.dto.care;

import com.ajudabem.api.domains.assisted_person.Gender;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.care.CareStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.ajudabem.api.dto.assited_person.AssistedPersonTagResponseDTO;
import com.ajudabem.api.dto.organization.OrganizationSummaryDTO;

import java.time.LocalDateTime;
import java.util.List;

public record CareCaseResponseDTO(
        Long id,
        String fullName,
        Integer age,
        Gender gender,
        RiskLevel riskLevel,
        CareStatus careStatus,
        FinishReason finishReason,
        List<AssistedPersonTagResponseDTO> tags,
        String notes,
        String street,
        String number,
        String neighborhood,
        String city,
        String state,
        String zipCode,
        Double latitude,
        Double longitude,
        LocalDateTime createdAt,
        LocalDateTime careStartedAt,
        LocalDateTime careUpdatedAt,
        OrganizationSummaryDTO organization,
        Double distanceKm
) {

    public CareCaseResponseDTO withDistanceKm(Double km) {
        return new CareCaseResponseDTO(id, fullName, age, gender, riskLevel, careStatus, finishReason, tags, notes,
                street, number, neighborhood, city, state, zipCode, latitude, longitude, createdAt, careStartedAt,
                careUpdatedAt, organization, km);
    }
}

package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.initiative.ApplicationStatus;
import com.ajudabem.api.domains.initiative.Campaign;
import com.ajudabem.api.domains.initiative.VolunteerAction;
import com.ajudabem.api.domains.initiative.VolunteerApplication;
import com.ajudabem.api.dto.initiative.CampaignRequestDTO;
import com.ajudabem.api.dto.initiative.CampaignResponseDTO;
import com.ajudabem.api.dto.initiative.OrganizationContactDTO;
import com.ajudabem.api.dto.initiative.VolunteerActionRequestDTO;
import com.ajudabem.api.dto.initiative.VolunteerActionResponseDTO;
import com.ajudabem.api.dto.initiative.VolunteerApplicationResponseDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface InitiativeMapper {

    CampaignResponseDTO toResponse(Campaign campaign);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "organization", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "finishedAt", ignore = true)
    void apply(CampaignRequestDTO dto, @MappingTarget Campaign campaign);

    @Mapping(target = "id", source = "action.id")
    @Mapping(target = "finishedAt", source = "action.finishedAt")
    @Mapping(target = "status", source = "action.status")
    @Mapping(target = "acceptedCount", source = "acceptedCount")
    @Mapping(target = "pendingCount", source = "pendingCount")
    @Mapping(target = "myApplication", source = "myApplication")
    @Mapping(target = "contact", source = "contact")
    VolunteerActionResponseDTO toResponse(VolunteerAction action, long acceptedCount, long pendingCount,
                                          ApplicationStatus myApplication, OrganizationContactDTO contact);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "organization", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "finishedAt", ignore = true)
    void apply(VolunteerActionRequestDTO dto, @MappingTarget VolunteerAction action);

    @Mapping(target = "volunteerId", source = "volunteer.id")
    @Mapping(target = "name", source = "volunteer.name")
    @Mapping(target = "profileImage", source = "volunteer.profile_image")
    @Mapping(target = "phone", source = "volunteer.phone")
    VolunteerApplicationResponseDTO toResponse(VolunteerApplication application);
}

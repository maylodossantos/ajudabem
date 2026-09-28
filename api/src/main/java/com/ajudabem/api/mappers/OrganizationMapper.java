package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.dto.organization.OrganizationRequestDTO;
import com.ajudabem.api.dto.organization.OrganizationResponseDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface OrganizationMapper {

    OrganizationResponseDTO toResponse(Organization organization);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "owner", ignore = true)
    @Mapping(target = "cnpj", ignore = true)
    @Mapping(target = "state", ignore = true)
    @Mapping(target = "zipCode", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "submittedAt", ignore = true)
    @Mapping(target = "reviewedAt", ignore = true)
    @Mapping(target = "reviewedBy", ignore = true)
    @Mapping(target = "rejectionReason", ignore = true)
    @Mapping(target = "rejectionNote", ignore = true)
    @Mapping(target = "documents", ignore = true)
    void updateEntity(OrganizationRequestDTO dto, @MappingTarget Organization organization);
}

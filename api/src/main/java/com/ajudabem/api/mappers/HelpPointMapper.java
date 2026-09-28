package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.help_point.HelpPoint;
import com.ajudabem.api.dto.help_point.HelpPointRequestDTO;
import com.ajudabem.api.dto.help_point.HelpPointResponseDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface HelpPointMapper {

    HelpPointResponseDTO toResponse(HelpPoint helpPoint);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "deleted", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "latitude", ignore = true)
    @Mapping(target = "longitude", ignore = true)
    @Mapping(target = "state", ignore = true)
    @Mapping(target = "zipCode", ignore = true)
    @Mapping(target = "phone", ignore = true)
    @Mapping(target = "whatsapp", ignore = true)
    @Mapping(target = "services", ignore = true)
    @Mapping(target = "openingHours", ignore = true)
    @Mapping(target = "source", ignore = true)
    @Mapping(target = "externalId", ignore = true)
    void updateEntity(HelpPointRequestDTO dto, @MappingTarget HelpPoint helpPoint);
}

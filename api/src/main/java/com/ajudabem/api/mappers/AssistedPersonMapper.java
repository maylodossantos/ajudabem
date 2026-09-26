package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.dto.assited_person.AssistedPersonRequestDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonResponseDTO;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface AssistedPersonMapper {

    AssistedPersonResponseDTO toResponse(
            AssistedPerson person
    );

    @Mapping(target = "tags", ignore = true)
    AssistedPerson toEntity(
            AssistedPersonRequestDTO dto
    );

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "tags", ignore = true)
    void updateEntity(
            AssistedPersonRequestDTO dto,
            @MappingTarget AssistedPerson person
    );
}

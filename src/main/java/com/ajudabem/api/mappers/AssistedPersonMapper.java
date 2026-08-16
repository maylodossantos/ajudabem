package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.AssistedPersonTag;
import com.ajudabem.api.dto.assited_person.AssistedPersonRequestDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonResponseDTO;
import com.ajudabem.api.dto.assited_person.AssistedPersonTagResponseDTO;
import org.mapstruct.*;

import java.util.List;

@Mapper(componentModel = "spring")
public interface AssistedPersonMapper {

    AssistedPersonResponseDTO toResponse(
            AssistedPerson person,
            List<AssistedPersonTag> tags
    );

    AssistedPerson toEntity(
            AssistedPersonRequestDTO dto
    );

    @Mapping(source = "tag.id", target = "id")
    @Mapping(source = "tag.name", target = "name")
    AssistedPersonTagResponseDTO toTagResponse (
            AssistedPersonTag tag
    );

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity(
            AssistedPersonRequestDTO dto,
            @MappingTarget AssistedPerson person
    );
}

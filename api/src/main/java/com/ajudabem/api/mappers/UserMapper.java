package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.user.UpdateUserRequestDTO;
import com.ajudabem.api.dto.user.UserResponseDTO;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring")
public interface UserMapper {

    UserResponseDTO toResponse(User user);

    @Mapping(target = "profile_image", source = "profileImage")
    @Mapping(target = "birth_date", source = "birthDate")
    @Mapping(target = "cpf", ignore = true)
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity(UpdateUserRequestDTO dto, @MappingTarget User user);
}
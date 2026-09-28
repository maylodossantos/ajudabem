package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.care.CareRecord;
import com.ajudabem.api.dto.care.CareCaseResponseDTO;
import com.ajudabem.api.dto.care.CareRecordResponseDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface CareMapper {

    @Mapping(target = "fullName", source = "full_name")
    @Mapping(target = "zipCode", source = "zip_code")
    @Mapping(target = "distanceKm", ignore = true)
    CareCaseResponseDTO toCase(AssistedPerson person);

    CareRecordResponseDTO toRecord(CareRecord record);
}

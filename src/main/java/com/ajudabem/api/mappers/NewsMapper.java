package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring")
public interface NewsMapper {

    News toEntity(NewsRequestDTO dto);

    NewsResponseDTO toResponse(News news);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntity(NewsRequestDTO dto, @MappingTarget News news);
}
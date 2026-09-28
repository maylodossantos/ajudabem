package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.notification.Notification;
import com.ajudabem.api.dto.notification.NotificationResponseDTO;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface NotificationMapper {

    NotificationResponseDTO toResponse(Notification notification);
}

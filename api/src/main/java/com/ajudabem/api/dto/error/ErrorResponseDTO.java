package com.ajudabem.api.dto.error;

import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

public record ErrorResponseDTO ( String message, int status, LocalDateTime timestamp) {

    public static ErrorResponseDTO of(HttpStatus status, String message) {
        return new ErrorResponseDTO(message, status.value(), LocalDateTime.now());
    }
}

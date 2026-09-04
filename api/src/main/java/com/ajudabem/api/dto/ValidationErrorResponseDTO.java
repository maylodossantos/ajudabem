package com.ajudabem.api.dto;

import java.util.Map;

public record ValidationErrorResponseDTO (int status, String message, Map<String, String> errors) { }

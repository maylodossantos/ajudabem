package com.ajudabem.api.dto.error;

import java.util.Map;

public record ValidationErrorResponseDTO (int status, String message, Map<String, String> errors) { }

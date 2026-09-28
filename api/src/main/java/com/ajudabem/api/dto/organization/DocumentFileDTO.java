package com.ajudabem.api.dto.organization;

public record DocumentFileDTO(String fileName, String contentType, byte[] content) { }

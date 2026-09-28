package com.ajudabem.api.exceptions;

public class OrganizationDocumentNotFoundException extends RuntimeException {
    public OrganizationDocumentNotFoundException(String message) {
        super(message);
    }
}

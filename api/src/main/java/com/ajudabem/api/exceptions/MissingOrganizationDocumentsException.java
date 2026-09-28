package com.ajudabem.api.exceptions;

public class MissingOrganizationDocumentsException extends RuntimeException {
    public MissingOrganizationDocumentsException(String message) {
        super(message);
    }
}

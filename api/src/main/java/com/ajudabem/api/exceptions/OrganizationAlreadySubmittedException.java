package com.ajudabem.api.exceptions;

public class OrganizationAlreadySubmittedException extends RuntimeException {
    public OrganizationAlreadySubmittedException(String message) {
        super(message);
    }
}

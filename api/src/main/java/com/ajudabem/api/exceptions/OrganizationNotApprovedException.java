package com.ajudabem.api.exceptions;

public class OrganizationNotApprovedException extends RuntimeException {
    public OrganizationNotApprovedException(String message) {
        super(message);
    }
}

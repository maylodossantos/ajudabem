package com.ajudabem.api.exceptions;

public class OrganizationNotPendingException extends RuntimeException {
    public OrganizationNotPendingException(String message) {
        super(message);
    }
}

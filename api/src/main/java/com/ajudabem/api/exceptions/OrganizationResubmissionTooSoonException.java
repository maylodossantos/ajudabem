package com.ajudabem.api.exceptions;

public class OrganizationResubmissionTooSoonException extends RuntimeException {
    public OrganizationResubmissionTooSoonException(String message) {
        super(message);
    }
}

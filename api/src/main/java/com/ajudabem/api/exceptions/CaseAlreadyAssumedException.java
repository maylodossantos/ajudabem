package com.ajudabem.api.exceptions;

public class CaseAlreadyAssumedException extends RuntimeException {
    public CaseAlreadyAssumedException(String message) {
        super(message);
    }
}

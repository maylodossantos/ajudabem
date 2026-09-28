package com.ajudabem.api.exceptions;

public class CaseClosedException extends RuntimeException {
    public CaseClosedException(String message) {
        super(message);
    }
}

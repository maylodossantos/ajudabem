package com.ajudabem.api.exceptions;

public class CpfAlreadyExistsException extends RuntimeException {
    public CpfAlreadyExistsException(String message) {
        super(message);
    }
}

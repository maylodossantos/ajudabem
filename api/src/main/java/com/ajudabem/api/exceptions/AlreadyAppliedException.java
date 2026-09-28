package com.ajudabem.api.exceptions;

public class AlreadyAppliedException extends RuntimeException {
    public AlreadyAppliedException(String message) {
        super(message);
    }
}

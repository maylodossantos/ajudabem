package com.ajudabem.api.infra.validation;

public final class Digits {

    private Digits() {
    }

    public static String only(String value) {
        return value.replaceAll("\\D", "");
    }

    static boolean allSame(String digits) {
        return digits.chars().distinct().count() == 1;
    }
}

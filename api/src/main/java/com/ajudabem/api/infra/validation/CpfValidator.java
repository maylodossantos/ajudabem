package com.ajudabem.api.infra.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.regex.Pattern;

public class CpfValidator implements ConstraintValidator<ValidCpf, String> {

    private static final Pattern FORMAT = Pattern.compile("\\d{3}\\.?\\d{3}\\.?\\d{3}-?\\d{2}");

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        return value == null || isValidCpf(value);
    }

    public static boolean isValidCpf(String value) {
        if (!FORMAT.matcher(value).matches()) {
            return false;
        }

        String digits = digitsOnly(value);
        if (digits.chars().distinct().count() == 1) {
            return false;
        }

        return checkDigit(digits, 9) == digits.charAt(9) - '0'
                && checkDigit(digits, 10) == digits.charAt(10) - '0';
    }

    /** How CPFs are stored: just the 11 digits. */
    public static String digitsOnly(String value) {
        return value.replaceAll("\\D", "");
    }

    private static int checkDigit(String digits, int length) {
        int sum = 0;
        for (int i = 0; i < length; i++) {
            sum += (digits.charAt(i) - '0') * (length + 1 - i);
        }
        int remainder = (sum * 10) % 11;
        return remainder == 10 ? 0 : remainder;
    }
}

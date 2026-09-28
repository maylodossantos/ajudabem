package com.ajudabem.api.infra.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.regex.Pattern;

public class CnpjValidator implements ConstraintValidator<ValidCnpj, String> {

    private static final Pattern FORMAT = Pattern.compile("\\d{2}\\.?\\d{3}\\.?\\d{3}/?\\d{4}-?\\d{2}");
    private static final int[] FIRST_WEIGHTS = {5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
    private static final int[] SECOND_WEIGHTS = {6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        return value == null || isValidCnpj(value);
    }

    public static boolean isValidCnpj(String value) {
        if (!FORMAT.matcher(value).matches()) {
            return false;
        }

        String digits = Digits.only(value);
        if (Digits.allSame(digits)) {
            return false;
        }

        return checkDigit(digits, FIRST_WEIGHTS) == digits.charAt(12) - '0'
                && checkDigit(digits, SECOND_WEIGHTS) == digits.charAt(13) - '0';
    }

    private static int checkDigit(String digits, int[] weights) {
        int sum = 0;
        for (int i = 0; i < weights.length; i++) {
            sum += (digits.charAt(i) - '0') * weights[i];
        }
        int remainder = sum % 11;
        return remainder < 2 ? 0 : 11 - remainder;
    }
}

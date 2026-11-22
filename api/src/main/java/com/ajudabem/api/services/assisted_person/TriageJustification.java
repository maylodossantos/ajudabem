package com.ajudabem.api.services.assisted_person;

import java.util.Arrays;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public final class TriageJustification {

    private static final Pattern SENTENCE_END = Pattern.compile("(?<=[.!?])\\s+");

    private static final Pattern MENTIONS_LEVEL = Pattern.compile(
            "\\b(HIGH|MEDIUM|LOW)\\b|classifica[çc][ãa]o|classificad[oa]|n[íi]vel de risco",
            Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);

    private TriageJustification() {
    }

    public static String clean(String justification) {
        if (justification == null || justification.isBlank()) {
            return justification;
        }
        String kept = Arrays.stream(SENTENCE_END.split(justification.trim()))
                .filter(sentence -> !MENTIONS_LEVEL.matcher(sentence).find())
                .collect(Collectors.joining(" "));
        return kept.isBlank() ? justification.trim() : kept;
    }
}

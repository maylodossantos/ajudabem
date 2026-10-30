package com.ajudabem.api.security;

import com.ajudabem.api.controllers.IntegrationTestSupport;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.concurrent.atomic.AtomicInteger;

@Tag("security")
abstract class SecurityTestSupport extends IntegrationTestSupport {

    private static final AtomicInteger NEXT_IP = new AtomicInteger(1);
    private static final AtomicInteger NEXT_CPF = new AtomicInteger(100_000_000);

    @Autowired
    protected ObjectMapper objectMapper;

    protected static RequestPostProcessor fromIp(String ip) {
        return request -> {
            request.setRemoteAddr(ip);
            return request;
        };
    }

    protected static String newIp() {
        int n = NEXT_IP.getAndIncrement();
        return "10.0." + (n / 250) + "." + (n % 250 + 1);
    }

    protected static String newValidCpf() {
        String base = String.valueOf(NEXT_CPF.getAndIncrement()).substring(0, 9);
        String withFirst = base + checkDigit(base);
        return withFirst + checkDigit(withFirst);
    }

    private static int checkDigit(String digits) {
        int sum = 0;
        for (int i = 0; i < digits.length(); i++) {
            sum += (digits.charAt(i) - '0') * (digits.length() + 1 - i);
        }
        int rest = sum % 11;
        return rest < 2 ? 0 : 11 - rest;
    }

    protected String registerBody(String email, String password) {
        return """
                {"name":"%s","email":"%s","phone":"45999990000","cpf":"%s",
                 "birthDate":"2000-05-10","password":"%s","acceptedTerms":true}
                """.formatted(email, email, newValidCpf(), password);
    }

    protected String loginBody(String email, String password) throws Exception {
        return objectMapper.writeValueAsString(new LoginBody(email, password));
    }

    protected long idOf(String json) throws Exception {
        return objectMapper.readTree(json).get("id").asLong();
    }

    private record LoginBody(String email, String password) { }
}

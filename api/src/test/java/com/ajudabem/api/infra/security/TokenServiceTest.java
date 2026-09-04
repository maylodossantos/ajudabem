package com.ajudabem.api.infra.security;

import com.ajudabem.api.domains.user.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;

class TokenServiceTest {

    private final TokenService tokenService = new TokenService();

    @BeforeEach
    void setSecret() {
        ReflectionTestUtils.setField(tokenService, "secret", "test-secret-value");
    }

    @Test
    void generateToken_thenValidateToken_shouldReturnTheSameSubjectEmail() {
        User user = new User();
        user.setEmail("jane@example.com");

        String token = tokenService.generateToken(user);
        String subject = tokenService.validateToken(token);

        assertThat(token).isNotBlank();
        assertThat(subject).isEqualTo("jane@example.com");
    }

    @Test
    void validateToken_shouldReturnNull_whenTokenIsInvalid() {
        String subject = tokenService.validateToken("this-is-not-a-valid-jwt");

        assertThat(subject).isNull();
    }

    @Test
    void validateToken_shouldReturnNull_whenTokenWasSignedWithADifferentSecret() {
        User user = new User();
        user.setEmail("jane@example.com");
        String token = tokenService.generateToken(user);

        ReflectionTestUtils.setField(tokenService, "secret", "a-different-secret");

        String subject = tokenService.validateToken(token);

        assertThat(subject).isNull();
    }
}

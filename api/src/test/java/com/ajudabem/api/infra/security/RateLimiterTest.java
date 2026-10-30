package com.ajudabem.api.infra.security;

import org.junit.jupiter.api.Test;

import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;

class RateLimiterTest {

    private final RateLimiter rateLimiter = new RateLimiter();

    @Test
    void exceeds_shouldOnlyBeTrueAfterTheLimitIsPassed() {
        assertThat(rateLimiter.exceeds("key", 2, Duration.ofMinutes(1))).isFalse();
        assertThat(rateLimiter.exceeds("key", 2, Duration.ofMinutes(1))).isFalse();
        assertThat(rateLimiter.exceeds("key", 2, Duration.ofMinutes(1))).isTrue();
        assertThat(rateLimiter.exceeds("other", 2, Duration.ofMinutes(1))).isFalse();
    }

    @Test
    void isBlocked_shouldBeTrueOnceTheHitsReachTheLimitAndFalseAfterReset() {
        rateLimiter.exceeds("key", 2, Duration.ofMinutes(1));
        assertThat(rateLimiter.isBlocked("key", 2)).isFalse();

        rateLimiter.exceeds("key", 2, Duration.ofMinutes(1));
        assertThat(rateLimiter.isBlocked("key", 2)).isTrue();

        rateLimiter.reset("key");
        assertThat(rateLimiter.isBlocked("key", 2)).isFalse();
    }

    @Test
    void windowShouldStartOverOnceItEnds() throws InterruptedException {
        rateLimiter.exceeds("key", 1, Duration.ofMillis(50));
        assertThat(rateLimiter.exceeds("key", 1, Duration.ofMillis(50))).isTrue();

        Thread.sleep(80);

        assertThat(rateLimiter.isBlocked("key", 1)).isFalse();
        assertThat(rateLimiter.exceeds("key", 1, Duration.ofMillis(50))).isFalse();
    }
}

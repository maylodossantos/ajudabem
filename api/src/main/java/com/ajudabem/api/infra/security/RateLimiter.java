package com.ajudabem.api.infra.security;

import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimiter {

    private static final int CLEANUP_THRESHOLD = 10_000;

    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    public boolean exceeds(String key, int limit, Duration window) {
        Instant now = Instant.now();
        cleanUpIfLarge(now);
        Window current = windows.compute(key, (k, existing) ->
                existing == null || existing.isOver(now) ? new Window(now.plus(window), 1) : existing.hit());
        return current.hits() > limit;
    }

    public boolean isBlocked(String key, int limit) {
        Window current = windows.get(key);
        return current != null && !current.isOver(Instant.now()) && current.hits() >= limit;
    }

    public void reset(String key) {
        windows.remove(key);
    }

    private void cleanUpIfLarge(Instant now) {
        if (windows.size() > CLEANUP_THRESHOLD) {
            windows.values().removeIf(window -> window.isOver(now));
        }
    }

    private record Window(Instant endsAt, int hits) {

        boolean isOver(Instant now) {
            return !now.isBefore(endsAt);
        }

        Window hit() {
            return new Window(endsAt, hits + 1);
        }
    }
}

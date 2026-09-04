package com.ajudabem.api.dto.user;

import com.ajudabem.api.domains.user.User;

public record UserResponseSummaryDTO (Long id, String name, String email) { }

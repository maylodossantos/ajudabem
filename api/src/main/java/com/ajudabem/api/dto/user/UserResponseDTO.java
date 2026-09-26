package com.ajudabem.api.dto.user;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record UserResponseDTO (Long id, String name, String email, String phone, String profile_image, String cpf, UserRole role, LocalDate birth_date,
                               LocalDateTime createdAt, LocalDateTime updatedAt, LocalDateTime last_login_at, LocalDateTime termsAcceptedAt,
                               Boolean deleted, LocalDateTime deletedAt) { }

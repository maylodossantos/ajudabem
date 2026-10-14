package com.ajudabem.api.dto.news;

import com.ajudabem.api.dto.user.UserResponseSummaryDTO;

import java.time.LocalDateTime;

public record NewsResponseDTO(Long id, String title, String subtitle, UserResponseSummaryDTO author, String content,
                              String cover_image, String city, String state, LocalDateTime createdAt) { }

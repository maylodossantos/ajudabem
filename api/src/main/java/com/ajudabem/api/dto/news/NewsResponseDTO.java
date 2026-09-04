package com.ajudabem.api.dto.news;

import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.dto.user.UserResponseSummaryDTO;

public record NewsResponseDTO (Long id, String title, String subtitle, UserResponseSummaryDTO author, String content, String cover_image) { }

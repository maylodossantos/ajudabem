package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.user.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NewsRepository extends JpaRepository<News, Long> { }

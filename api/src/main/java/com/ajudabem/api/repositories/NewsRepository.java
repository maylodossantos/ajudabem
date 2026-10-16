package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.news.News;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NewsRepository extends JpaRepository<News, Long> {

    List<News> findAllByOrderByCreatedAtDesc();
}

package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.help_point.HelpPoint;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HelpPointRepository extends JpaRepository<HelpPoint, Long> {

    List<HelpPoint> findAllByOrderByCreatedAtDesc();
}

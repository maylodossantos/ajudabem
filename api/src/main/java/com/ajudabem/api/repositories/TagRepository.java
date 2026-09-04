package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TagRepository extends JpaRepository<Tag, Long> { }

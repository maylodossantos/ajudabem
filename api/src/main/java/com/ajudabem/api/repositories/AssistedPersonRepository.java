package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AssistedPersonRepository extends JpaRepository<AssistedPerson, Long> { }

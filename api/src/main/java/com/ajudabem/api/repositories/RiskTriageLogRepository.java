package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.RiskTriageLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RiskTriageLogRepository extends JpaRepository<RiskTriageLog, Long> {

    Optional<RiskTriageLog> findFirstByAssistedPersonOrderByCreatedAtDesc(AssistedPerson assistedPerson);
}

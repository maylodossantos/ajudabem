package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.user.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public interface AssistedPersonRepository extends JpaRepository<AssistedPerson, Long> {

    List<AssistedPerson> findAllByAuthor(User author);

    /** Oldest people still waiting for risk triage (tags loaded for the prompt). */
    @EntityGraph(attributePaths = "tags")
    List<AssistedPerson> findTop20ByRiskLevelIsNullOrderByCreatedAtAsc();

    /**
     * Sets the triaged level only while the person is still pending, touching
     * no other column - so it can't overwrite an edit made during triage.
     */
    @Modifying
    @Transactional
    @Query("update AssistedPerson p set p.riskLevel = :riskLevel where p.id = :id and p.riskLevel is null")
    int updateRiskLevelIfPending(@Param("id") Long id, @Param("riskLevel") RiskLevel riskLevel);
}

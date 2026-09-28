package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.care.CareStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.user.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.List;

public interface AssistedPersonRepository extends JpaRepository<AssistedPerson, Long> {

    List<AssistedPerson> findAllByAuthor(User author);

    @EntityGraph(attributePaths = "tags")
    List<AssistedPerson> findAllByCareStatusOrderByCreatedAtDesc(CareStatus careStatus);

    @EntityGraph(attributePaths = "tags")
    List<AssistedPerson> findAllByCareStatusInOrderByCareUpdatedAtDesc(Collection<CareStatus> careStatuses);

    @EntityGraph(attributePaths = "tags")
    List<AssistedPerson> findAllByOrganizationOrderByCareUpdatedAtDesc(Organization organization);

    @EntityGraph(attributePaths = "tags")
    List<AssistedPerson> findTop20ByRiskLevelIsNullOrderByCreatedAtAsc();

    @EntityGraph(attributePaths = "tags")
    List<AssistedPerson> findAllByCareStatusInAndLatitudeIsNotNull(Collection<CareStatus> careStatuses);

    long countByCareStatus(CareStatus careStatus);

    long countByCareStatusAndFinishReason(CareStatus careStatus, FinishReason finishReason);

    long countByOrganization(Organization organization);

    @Modifying
    @Transactional
    @Query("update AssistedPerson p set p.riskLevel = :riskLevel where p.id = :id and p.riskLevel is null")
    int updateRiskLevelIfPending(@Param("id") Long id, @Param("riskLevel") RiskLevel riskLevel);
}

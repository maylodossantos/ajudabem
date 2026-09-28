package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.care.CareRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CareRecordRepository extends JpaRepository<CareRecord, Long> {

    List<CareRecord> findAllByAssistedPersonOrderByNumberAsc(AssistedPerson assistedPerson);

    int countByAssistedPerson(AssistedPerson assistedPerson);
}

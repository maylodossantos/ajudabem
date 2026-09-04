package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.AssistedPersonTag;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AssistedPersonTagRepository extends JpaRepository<AssistedPersonTag, Long>  {
    List<AssistedPersonTag> findByAssistedPerson(AssistedPerson assistedPerson);

    @Transactional
    void deleteByAssistedPerson(AssistedPerson assistedPerson);
}

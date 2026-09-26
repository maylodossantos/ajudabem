package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class AssistedPersonTriageQueriesTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private AssistedPersonRepository repository;

    private AssistedPerson persistPerson(String name, RiskLevel riskLevel) {
        User author = new User();
        author.setName("Author");
        author.setEmail(name + "@example.com");
        author.setPassword("irrelevant");
        author.setRole(UserRole.USER);
        entityManager.persist(author);

        AssistedPerson person = new AssistedPerson();
        person.setFull_name(name);
        person.setAuthor(author);
        person.setRiskLevel(riskLevel);
        return entityManager.persist(person);
    }

    @Test
    void findPending_shouldOnlyReturnPeopleWithoutRiskLevel() {
        persistPerson("Maria", null);
        persistPerson("João", RiskLevel.HIGH);
        entityManager.flush();
        entityManager.clear();

        assertThat(repository.findTop20ByRiskLevelIsNullOrderByCreatedAtAsc())
                .extracting(AssistedPerson::getFull_name)
                .containsExactly("Maria");
    }

    @Test
    void updateRiskLevelIfPending_shouldSetThePendingLevelButNeverOverwriteAnExistingOne() {
        Long pendingId = persistPerson("Maria", null).getId();
        Long triagedId = persistPerson("João", RiskLevel.LOW).getId();
        entityManager.flush();

        assertThat(repository.updateRiskLevelIfPending(pendingId, RiskLevel.HIGH)).isEqualTo(1);
        assertThat(repository.updateRiskLevelIfPending(triagedId, RiskLevel.HIGH)).isZero();

        entityManager.clear();
        assertThat(repository.findById(pendingId)).get()
                .extracting(AssistedPerson::getRiskLevel).isEqualTo(RiskLevel.HIGH);
        assertThat(repository.findById(triagedId)).get()
                .extracting(AssistedPerson::getRiskLevel).isEqualTo(RiskLevel.LOW);
    }
}

package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

// Regression test for the soft-delete convention: EntityBase.softDelete() only flips a flag,
// so every entity needs @SQLRestriction("deleted = false") or soft-deleted rows stay visible
// forever through the normal repository methods (findAll/findById/findByEmail).
//
// flush()+clear() below forces a real round-trip to the DB: findById() on an entity still
// managed in the same session returns it straight from Hibernate's identity map, skipping
// SQL (and the restriction) entirely - a same-session artifact, not how separate HTTP
// requests behave in production, but it would still make this test lie if left in place.
@DataJpaTest
class SoftDeleteFilteringTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NewsRepository newsRepository;

    @Autowired
    private AssistedPersonRepository assistedPersonRepository;

    @Autowired
    private TagRepository tagRepository;

    private User persistUser(String email) {
        User user = new User();
        user.setName("User");
        user.setEmail(email);
        user.setPassword("hashed");
        user.setPhone("49999990000");
        user.setRole(UserRole.USER);
        return userRepository.save(user);
    }

    @Test
    void softDeletedUserIsExcludedFromFindByEmailAndFindAll() {
        User user = persistUser("deleted@example.com");
        user.softDelete();
        userRepository.save(user);

        assertThat(userRepository.findByEmail("deleted@example.com")).isEmpty();
        assertThat(userRepository.findAll()).extracting(User::getId).doesNotContain(user.getId());
    }

    @Test
    void softDeletedNewsIsExcludedFromFindAllAndFindById() {
        User author = persistUser("author@example.com");

        News news = new News();
        news.setAuthor(author);
        news.setTitle("Título");
        news.setContent("Conteúdo");
        newsRepository.save(news);

        news.softDelete();
        newsRepository.save(news);
        entityManager.flush();
        entityManager.clear();

        assertThat(newsRepository.findById(news.getId())).isEmpty();
        assertThat(newsRepository.findAll()).isEmpty();
    }

    @Test
    void softDeletedAssistedPersonIsExcludedFromFindAll() {
        User author = persistUser("author2@example.com");

        AssistedPerson person = new AssistedPerson();
        person.setAuthor(author);
        person.setFull_name("Maria");
        assistedPersonRepository.save(person);

        person.softDelete();
        assistedPersonRepository.save(person);

        assertThat(assistedPersonRepository.findAll()).isEmpty();
    }

    @Test
    void assistedPersonTagsAreLoadedThroughTheJoinTable() {
        User author = persistUser("author3@example.com");
        Tag tag = tagRepository.save(new Tag(null, "Alimentação"));

        AssistedPerson person = new AssistedPerson();
        person.setAuthor(author);
        person.setFull_name("João");
        person.setTags(List.of(tag));
        assistedPersonRepository.save(person);
        entityManager.flush();
        entityManager.clear();

        AssistedPerson reloaded = assistedPersonRepository.findById(person.getId()).orElseThrow();

        assertThat(reloaded.getTags()).extracting(Tag::getId).containsExactly(tag.getId());
    }
}

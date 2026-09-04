package com.ajudabem.api.integration;

import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.NewsRepository;
import com.ajudabem.api.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

// Integration test: real Spring Data JPA repositories against a real (H2) database,
// no mocks — verifies the entity mapping and EntityBase lifecycle callbacks actually work,
// which a mocked-repository unit test (see services/news/NewsServiceTest) can't catch.
@DataJpaTest
class NewsRepositoryIntegrationTest {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NewsRepository newsRepository;

    @Test
    void savesAndReloadsNewsWithItsAuthor() {
        User author = new User();
        author.setName("Maria Autora");
        author.setEmail("maria.autora@example.com");
        author.setPassword("hashed-password");
        author.setPhone("49999990000");
        author.setRole(UserRole.USER);
        userRepository.save(author);

        News news = new News();
        news.setAuthor(author);
        news.setTitle("Campanha do agasalho começa nesta semana");
        news.setSubtitle("Doações podem ser feitas em qualquer unidade parceira");
        news.setContent("Texto completo da notícia.");
        newsRepository.save(news);

        Optional<News> reloaded = newsRepository.findById(news.getId());

        assertThat(reloaded).isPresent();
        assertThat(reloaded.get().getTitle()).isEqualTo("Campanha do agasalho começa nesta semana");
        assertThat(reloaded.get().getAuthor().getEmail()).isEqualTo("maria.autora@example.com");
        assertThat(reloaded.get().getDeleted()).isFalse();
        assertThat(reloaded.get().getCreatedAt()).isNotNull();
    }

    @Test
    void softDeletedNewsIsStillPersistedButFlaggedAsDeleted() {
        User author = new User();
        author.setName("Joao Autor");
        author.setEmail("joao.autor@example.com");
        author.setPassword("hashed-password");
        author.setPhone("49988880000");
        author.setRole(UserRole.USER);
        userRepository.save(author);

        News news = new News();
        news.setAuthor(author);
        news.setTitle("Notícia a ser removida");
        news.setContent("Conteúdo qualquer.");
        newsRepository.save(news);

        news.softDelete();
        newsRepository.save(news);

        Optional<News> reloaded = newsRepository.findById(news.getId());

        assertThat(reloaded).isPresent();
        assertThat(reloaded.get().getDeleted()).isTrue();
        assertThat(reloaded.get().getDeletedAt()).isNotNull();
    }
}

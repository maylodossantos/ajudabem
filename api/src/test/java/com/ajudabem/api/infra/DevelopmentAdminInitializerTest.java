package com.ajudabem.api.infra;

import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.auth.LoginRequestDTO;
import com.ajudabem.api.repositories.UserRepository;
import com.ajudabem.api.services.user.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.DefaultApplicationArguments;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("dev")
@Transactional
class DevelopmentAdminInitializerTest {
    @Autowired private UserRepository repository;
    @Autowired private PasswordEncoder encoder;
    @Autowired private DevelopmentAdminInitializer initializer;
    @Autowired private UserService userService;

    @Test
    void seededAdminShouldAuthenticateUsingTheNormalLogin() {
        var admin = repository.findByEmail("admin@ajudabem.local").orElseThrow();
        assertThat(admin.getRole()).isEqualTo(UserRole.ADMIN);
        assertThat(admin.getTermsAcceptedAt()).isNotNull();
        assertThat(admin.getPassword()).isNotEqualTo("Admin@123456");
        assertThat(encoder.matches("Admin@123456", admin.getPassword())).isTrue();
        var response = userService.login(new LoginRequestDTO("admin@ajudabem.local", "Admin@123456"));
        assertThat(response.token()).isNotBlank();
    }

    @Test
    void restartingShouldNotDuplicateOrOverwriteAnExistingAccount() {
        var admin = repository.findByEmail("admin@ajudabem.local").orElseThrow();
        var id = admin.getId();
        var count = repository.count();
        admin.setPassword(encoder.encode("Changed@123456"));
        admin.setRole(UserRole.USER);
        repository.saveAndFlush(admin);
        initializer.run(new DefaultApplicationArguments());
        var existing = repository.findByEmail("admin@ajudabem.local").orElseThrow();
        assertThat(repository.count()).isEqualTo(count);
        assertThat(existing.getId()).isEqualTo(id);
        assertThat(existing.getRole()).isEqualTo(UserRole.USER);
        assertThat(encoder.matches("Changed@123456", existing.getPassword())).isTrue();
    }

    @Test
    void productionAndOtherProfilesShouldNotLoadTheInitializer() {
        for (String profiles : new String[]{"prod", "production", "test", "dev,prod", "dev,production"}) {
            new ApplicationContextRunner()
                    .withPropertyValues("spring.profiles.active=" + profiles)
                    .withUserConfiguration(DevelopmentAdminInitializer.class)
                    .run(context -> assertThat(context).doesNotHaveBean(DevelopmentAdminInitializer.class));
        }
    }
}

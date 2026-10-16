package com.ajudabem.api.infra;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;

/** Reproducible local account; never loaded outside the development profile. */
@Component
@Profile("dev & !prod & !production")
@RequiredArgsConstructor
@Slf4j
public class DevelopmentAdminInitializer implements ApplicationRunner {
    private final UserRepository repository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        String email = "admin@ajudabem.local";
        if (repository.findByEmail(email).isPresent()) {
            return;
        }

        User admin = new User();
        admin.setName("Administrador de Desenvolvimento");
        admin.setEmail(email);
        admin.setPassword(passwordEncoder.encode("Admin@123456"));
        admin.setRole(UserRole.ADMIN);
        admin.setPhone("11999999999");
        admin.setBirth_date(LocalDate.of(1990, 1, 1));
        admin.setTermsAcceptedAt(LocalDateTime.now());
        repository.save(admin);
        log.info("Development administrator created: {}", email);
    }
}

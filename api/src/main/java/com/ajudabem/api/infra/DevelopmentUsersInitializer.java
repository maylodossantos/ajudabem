package com.ajudabem.api.infra;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.OrganizationRepository;
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
import java.util.Optional;

@Component
@Profile("dev & !prod & !production")
@RequiredArgsConstructor
@Slf4j
public class DevelopmentUsersInitializer implements ApplicationRunner {

    public static final String ADMIN_EMAIL = "admin@ajudabem.local";
    public static final String ADMIN_PASSWORD = "Admin@123456";
    public static final String USER_EMAIL = "usuario@ajudabem.local";
    public static final String USER_PASSWORD = "Usuario@123456";
    public static final String ONG_EMAIL = "ong@ajudabem.local";
    public static final String ONG_PASSWORD = "Ong@123456";
    public static final String ONG_CNPJ = "99887766000105";
    public static final String ONG2_EMAIL = "ong2@ajudabem.local";
    public static final String ONG2_PASSWORD = "Ong2@123456";
    public static final String ONG2_CNPJ = "11222333000181";

    private final UserRepository repository;
    private final OrganizationRepository organizationRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        User admin = create(ADMIN_EMAIL, ADMIN_PASSWORD, "Administrador de Desenvolvimento", UserRole.ADMIN,
                "11999999999")
                .orElseGet(() -> repository.findByEmail(ADMIN_EMAIL).orElseThrow());
        create(USER_EMAIL, USER_PASSWORD, "Usuário de Desenvolvimento", UserRole.USER, "11999999998");
        User ong = create(ONG_EMAIL, ONG_PASSWORD, "ONG de Desenvolvimento", UserRole.USER_ONG, "11999999997")
                .orElseGet(() -> repository.findByEmail(ONG_EMAIL).orElseThrow());
        if (ong.getRole() == UserRole.USER_ONG) {
            approvedOrganization(ong, admin, new SeedOrganization(ONG_CNPJ,
                    "Associação AjudaBem de Desenvolvimento", "ONG Dev",
                    "Rua Paraná", "3000", "Centro", "85810010", -24.9558, -53.4560));
        }
        User ong2 = create(ONG2_EMAIL, ONG2_PASSWORD, "ONG 2 de Desenvolvimento", UserRole.USER_ONG, "11999999996")
                .orElseGet(() -> repository.findByEmail(ONG2_EMAIL).orElseThrow());
        if (ong2.getRole() == UserRole.USER_ONG) {
            approvedOrganization(ong2, admin, new SeedOrganization(ONG2_CNPJ,
                    "Instituto AjudaBem Zona Oeste", "ONG Dev 2",
                    "Avenida Brasil", "5000", "Centro", "85812000", -24.9530, -53.4630));
        }
    }

    private record SeedOrganization(String cnpj, String corporateName, String tradeName, String street,
                                    String number, String neighborhood, String zipCode,
                                    double latitude, double longitude) {
    }

    private Optional<User> create(String email, String password, String name, UserRole role, String phone) {
        if (repository.findByEmail(email).isPresent()) {
            return Optional.empty();
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setRole(role);
        user.setPhone(phone);
        user.setBirth_date(LocalDate.of(1990, 1, 1));
        user.setTermsAcceptedAt(LocalDateTime.now());
        repository.save(user);
        log.info("Development {} created: {}", role, email);
        return Optional.of(user);
    }

    private void approvedOrganization(User owner, User reviewer, SeedOrganization seed) {
        if (organizationRepository.findByOwner(owner).isPresent()
                || organizationRepository.findByCnpj(seed.cnpj()).isPresent()) {
            return;
        }

        LocalDateTime now = LocalDateTime.now();
        Organization organization = new Organization();
        organization.setOwner(owner);
        organization.setCorporateName(seed.corporateName());
        organization.setTradeName(seed.tradeName());
        organization.setCnpj(seed.cnpj());
        organization.setActivityArea("Assistência social");
        organization.setStreet(seed.street());
        organization.setNumber(seed.number());
        organization.setNeighborhood(seed.neighborhood());
        organization.setCity("Cascavel");
        organization.setState("PR");
        organization.setZipCode(seed.zipCode());
        organization.setLatitude(seed.latitude());
        organization.setLongitude(seed.longitude());
        organization.setStatus(OrganizationStatus.APPROVED);
        organization.setSubmittedAt(now);
        organization.setReviewedAt(now);
        organization.setReviewedBy(reviewer);
        organizationRepository.save(organization);
    }
}

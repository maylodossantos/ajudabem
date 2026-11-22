package com.ajudabem.api.infra;

import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.auth.LoginRequestDTO;
import com.ajudabem.api.repositories.OrganizationRepository;
import com.ajudabem.api.repositories.UserRepository;
import com.ajudabem.api.services.organization.OrganizationAccessService;
import com.ajudabem.api.services.user.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.DefaultApplicationArguments;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import static com.ajudabem.api.infra.DevelopmentUsersInitializer.ADMIN_EMAIL;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.ADMIN_PASSWORD;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.ONG2_EMAIL;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.ONG2_PASSWORD;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.ONG_EMAIL;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.ONG_PASSWORD;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.USER_EMAIL;
import static com.ajudabem.api.infra.DevelopmentUsersInitializer.USER_PASSWORD;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("dev")
@Transactional
class DevelopmentUsersInitializerTest {
    @Autowired private UserRepository repository;
    @Autowired private OrganizationRepository organizationRepository;
    @Autowired private OrganizationAccessService organizationAccess;
    @Autowired private PasswordEncoder encoder;
    @Autowired private DevelopmentUsersInitializer initializer;
    @Autowired private UserService userService;

    @Test
    void seededAdminShouldAuthenticateUsingTheNormalLogin() {
        var admin = repository.findByEmail(ADMIN_EMAIL).orElseThrow();
        assertThat(admin.getRole()).isEqualTo(UserRole.ADMIN);
        assertThat(admin.getTermsAcceptedAt()).isNotNull();
        assertThat(admin.getPassword()).isNotEqualTo(ADMIN_PASSWORD);
        assertThat(encoder.matches(ADMIN_PASSWORD, admin.getPassword())).isTrue();
        var response = userService.login(new LoginRequestDTO(ADMIN_EMAIL, ADMIN_PASSWORD));
        assertThat(response.token()).isNotBlank();
    }

    @Test
    void seededUserAndOngShouldLogInWithTheirRoles() {
        assertThat(repository.findByEmail(USER_EMAIL).orElseThrow().getRole()).isEqualTo(UserRole.USER);
        assertThat(userService.login(new LoginRequestDTO(USER_EMAIL, USER_PASSWORD)).token()).isNotBlank();

        var ong = repository.findByEmail(ONG_EMAIL).orElseThrow();
        assertThat(ong.getRole()).isEqualTo(UserRole.USER_ONG);
        assertThat(userService.login(new LoginRequestDTO(ONG_EMAIL, ONG_PASSWORD)).token()).isNotBlank();
        var organization = organizationAccess.approvedOf(ong);
        assertThat(organization.getStatus()).isEqualTo(OrganizationStatus.APPROVED);
        assertThat(organization.getReviewedBy().getEmail()).isEqualTo(ADMIN_EMAIL);
    }

    @Test
    void seededSecondOngShouldHaveItsOwnApprovedOrganization() {
        var ong = repository.findByEmail(ONG_EMAIL).orElseThrow();
        var ong2 = repository.findByEmail(ONG2_EMAIL).orElseThrow();
        assertThat(ong2.getRole()).isEqualTo(UserRole.USER_ONG);
        assertThat(userService.login(new LoginRequestDTO(ONG2_EMAIL, ONG2_PASSWORD)).token()).isNotBlank();
        var organization = organizationAccess.approvedOf(ong2);
        assertThat(organization.getStatus()).isEqualTo(OrganizationStatus.APPROVED);
        assertThat(organization.getId()).isNotEqualTo(organizationAccess.approvedOf(ong).getId());
    }

    @Test
    void restartingShouldNotDuplicateOrOverwriteAnExistingAccount() {
        var admin = repository.findByEmail(ADMIN_EMAIL).orElseThrow();
        var id = admin.getId();
        var count = repository.count();
        var organizations = organizationRepository.count();
        admin.setPassword(encoder.encode("Changed@123456"));
        admin.setRole(UserRole.USER);
        repository.saveAndFlush(admin);
        initializer.run(new DefaultApplicationArguments());
        var existing = repository.findByEmail(ADMIN_EMAIL).orElseThrow();
        assertThat(repository.count()).isEqualTo(count);
        assertThat(organizationRepository.count()).isEqualTo(organizations);
        assertThat(existing.getId()).isEqualTo(id);
        assertThat(existing.getRole()).isEqualTo(UserRole.USER);
        assertThat(encoder.matches("Changed@123456", existing.getPassword())).isTrue();
    }

    @Test
    void restartingShouldGiveAnExistingOngAccountWithoutOrganizationItsApprovedOrganization() {
        var ong = repository.findByEmail(ONG_EMAIL).orElseThrow();
        organizationRepository.delete(organizationRepository.findByOwner(ong).orElseThrow());
        organizationRepository.flush();
        assertThat(organizationRepository.findByOwner(ong)).isEmpty();

        initializer.run(new DefaultApplicationArguments());

        assertThat(organizationAccess.approvedOf(ong).getStatus()).isEqualTo(OrganizationStatus.APPROVED);
    }

    @Test
    void productionAndOtherProfilesShouldNotLoadTheInitializer() {
        for (String profiles : new String[]{"prod", "production", "test", "dev,prod", "dev,production"}) {
            new ApplicationContextRunner()
                    .withPropertyValues("spring.profiles.active=" + profiles)
                    .withUserConfiguration(DevelopmentUsersInitializer.class)
                    .run(context -> assertThat(context).doesNotHaveBean(DevelopmentUsersInitializer.class));
        }
    }
}

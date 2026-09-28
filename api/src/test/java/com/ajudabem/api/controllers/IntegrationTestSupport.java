package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.repositories.OrganizationRepository;
import com.ajudabem.api.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
abstract class IntegrationTestSupport {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected UserRepository userRepository;

    @Autowired
    protected OrganizationRepository organizationRepository;

    @Autowired
    protected TokenService tokenService;

    protected User saveUser(String email, UserRole role) {
        User user = new User();
        user.setName(email);
        user.setEmail(email);
        user.setPassword("irrelevant");
        user.setRole(role);
        return userRepository.save(user);
    }

    protected User approvedOng(String email, String cnpj) {
        User owner = saveUser(email, UserRole.USER_ONG);
        Organization organization = new Organization();
        organization.setOwner(owner);
        organization.setTradeName("ONG " + email);
        organization.setCnpj(cnpj);
        organization.setStatus(OrganizationStatus.APPROVED);
        organizationRepository.save(organization);
        return owner;
    }

    protected String bearer(User user) {
        return "Bearer " + tokenService.generateToken(user);
    }
}

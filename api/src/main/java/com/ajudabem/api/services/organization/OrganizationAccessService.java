package com.ajudabem.api.services.organization;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.repositories.OrganizationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class OrganizationAccessService {

    private final OrganizationRepository organizationRepository;

    public Optional<Organization> of(User user) {
        return user.getRole() == UserRole.USER_ONG ? organizationRepository.findByOwner(user) : Optional.empty();
    }

    public Organization approvedOf(User user) {
        return of(user)
                .filter(organization -> organization.getStatus() == OrganizationStatus.APPROVED)
                .orElseThrow(() -> new ForbiddenActionException("Only approved organizations can do this"));
    }

    public static void requireSame(Organization expected, Organization actual) {
        if (expected == null || actual == null || !Objects.equals(expected.getId(), actual.getId())) {
            throw new ForbiddenActionException("Only the organization in charge can do this");
        }
    }
}

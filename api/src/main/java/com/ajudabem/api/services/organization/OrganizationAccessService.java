package com.ajudabem.api.services.organization;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.care.CareStatus;
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

    public boolean canSeeCase(User user, AssistedPerson person) {
        return canSeeCase(user, of(user).orElse(null), person);
    }

    public static boolean canSeeCase(User user, Organization organization, AssistedPerson person) {
        if (user.getRole() == UserRole.ADMIN || person.getCareStatus() == CareStatus.NOMINATED) {
            return true;
        }
        return organization != null && person.getOrganization() != null
                && Objects.equals(organization.getId(), person.getOrganization().getId());
    }

    public void requireCaseAccess(User user, AssistedPerson person) {
        if (!canSeeCase(user, person)) {
            throw new ForbiddenActionException("Only the organization in charge can see this case");
        }
    }

    public static void requireSame(Organization expected, Organization actual) {
        if (expected == null || actual == null || !Objects.equals(expected.getId(), actual.getId())) {
            throw new ForbiddenActionException("Only the organization in charge can do this");
        }
    }
}

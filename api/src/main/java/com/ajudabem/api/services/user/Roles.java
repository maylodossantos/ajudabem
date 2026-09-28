package com.ajudabem.api.services.user;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.exceptions.ForbiddenActionException;

public final class Roles {

    private Roles() {
    }

    public static User requireAdmin(User user, String message) {
        if (user.getRole() != UserRole.ADMIN) {
            throw new ForbiddenActionException(message);
        }
        return user;
    }
}

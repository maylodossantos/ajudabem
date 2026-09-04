package com.ajudabem.api.services.user;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.exceptions.UserNotFoundException;
import com.ajudabem.api.repositories.UserRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CurrentUserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private CurrentUserService currentUserService;

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void get_shouldReturnUser_whenAuthenticatedEmailExists() {
        User user = new User();
        user.setEmail("jane@example.com");

        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken("jane@example.com", null));
        when(userRepository.findByEmail("jane@example.com")).thenReturn(Optional.of(user));

        User result = currentUserService.get();

        assertThat(result).isEqualTo(user);
    }

    @Test
    void get_shouldThrowUserNotFoundException_whenAuthenticatedEmailHasNoUser() {
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken("ghost@example.com", null));
        when(userRepository.findByEmail("ghost@example.com")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> currentUserService.get())
                .isInstanceOf(UserNotFoundException.class);
    }
}

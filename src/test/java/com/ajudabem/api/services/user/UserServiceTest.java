package com.ajudabem.api.services.user;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.auth.LoginRequestDTO;
import com.ajudabem.api.dto.auth.RegisterRequestDTO;
import com.ajudabem.api.dto.auth.ResponseDTO;
import com.ajudabem.api.dto.user.UpdateUserRequestDTO;
import com.ajudabem.api.dto.user.UserResponseDTO;
import com.ajudabem.api.exceptions.EmailAlreadyExistsException;
import com.ajudabem.api.exceptions.InvalidPasswordException;
import com.ajudabem.api.exceptions.UserAlreadyDeletedException;
import com.ajudabem.api.exceptions.UserNotFoundException;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.mappers.UserMapper;
import com.ajudabem.api.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository repository;

    @Mock
    private UserMapper mapper;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private TokenService tokenService;

    @Mock
    private CurrentUserService currentUserService;

    @InjectMocks
    private UserService userService;

    private User existingUser() {
        User user = new User();
        user.setId(1L);
        user.setName("Jane Doe");
        user.setEmail("jane@example.com");
        user.setPassword("hashed-password");
        user.setRole(UserRole.USER);
        user.setDeleted(false);
        return user;
    }

    @Test
    void register_shouldCreateUserAndReturnToken_whenEmailNotUsed() {
        RegisterRequestDTO dto = new RegisterRequestDTO("Jane Doe", "jane@example.com", "11999999999", "secret123");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.empty());
        when(passwordEncoder.encode(dto.password())).thenReturn("hashed-password");
        when(tokenService.generateToken(any(User.class))).thenReturn("generated-token");

        ResponseDTO result = userService.register(dto);

        assertThat(result.name()).isEqualTo("Jane Doe");
        assertThat(result.token()).isEqualTo("generated-token");
        verify(repository).save(argThat(user ->
                user.getEmail().equals("jane@example.com")
                        && user.getPassword().equals("hashed-password")
                        && user.getRole() == UserRole.USER
        ));
    }

    @Test
    void register_shouldThrowEmailAlreadyExistsException_whenEmailAlreadyUsed() {
        RegisterRequestDTO dto = new RegisterRequestDTO("Jane Doe", "jane@example.com", "11999999999", "secret123");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(existingUser()));

        assertThatThrownBy(() -> userService.register(dto))
                .isInstanceOf(EmailAlreadyExistsException.class)
                .hasMessage("Email is using");

        verify(repository, never()).save(any());
    }

    @Test
    void login_shouldReturnToken_whenCredentialsAreValid() {
        User user = existingUser();
        LoginRequestDTO dto = new LoginRequestDTO("jane@example.com", "secret123");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(dto.password(), user.getPassword())).thenReturn(true);
        when(tokenService.generateToken(user)).thenReturn("generated-token");

        ResponseDTO result = userService.login(dto);

        assertThat(result.name()).isEqualTo("Jane Doe");
        assertThat(result.token()).isEqualTo("generated-token");
        verify(repository).save(user);
    }

    @Test
    void login_shouldThrowUserNotFoundException_whenEmailDoesNotExist() {
        LoginRequestDTO dto = new LoginRequestDTO("missing@example.com", "secret123");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.login(dto))
                .isInstanceOf(UserNotFoundException.class);
    }

    @Test
    void login_shouldThrowInvalidPasswordException_whenPasswordDoesNotMatch() {
        User user = existingUser();
        LoginRequestDTO dto = new LoginRequestDTO("jane@example.com", "wrong-password");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(dto.password(), user.getPassword())).thenReturn(false);

        assertThatThrownBy(() -> userService.login(dto))
                .isInstanceOf(InvalidPasswordException.class);

        verify(tokenService, never()).generateToken(any());
    }

    @Test
    void getCurrentUser_shouldReturnMappedUser() {
        User user = existingUser();
        UserResponseDTO expected = mock(UserResponseDTO.class);

        when(currentUserService.get()).thenReturn(user);
        when(mapper.toResponse(user)).thenReturn(expected);

        UserResponseDTO result = userService.getCurrentUser();

        assertThat(result).isEqualTo(expected);
    }

    @Test
    void updateCurrentUser_shouldMapAndSaveUser() {
        User user = existingUser();
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO("New Name", null, null);
        UserResponseDTO expected = mock(UserResponseDTO.class);

        when(currentUserService.get()).thenReturn(user);
        when(mapper.toResponse(user)).thenReturn(expected);

        UserResponseDTO result = userService.updateCurrentUser(dto);

        verify(mapper).updateEntity(dto, user);
        verify(repository).save(user);
        assertThat(result).isEqualTo(expected);
    }

    @Test
    void deleteMe_shouldSoftDeleteAndSaveUser_whenNotAlreadyDeleted() {
        User user = existingUser();

        when(currentUserService.get()).thenReturn(user);

        userService.deleteMe();

        assertThat(user.getDeleted()).isTrue();
        verify(repository).save(user);
    }

    @Test
    void deleteMe_shouldThrowUserAlreadyDeletedException_whenAlreadyDeleted() {
        User user = existingUser();
        user.setDeleted(true);

        when(currentUserService.get()).thenReturn(user);

        assertThatThrownBy(() -> userService.deleteMe())
                .isInstanceOf(UserAlreadyDeletedException.class)
                .hasMessage("User already deleted");

        verify(repository, never()).save(any());
    }
}

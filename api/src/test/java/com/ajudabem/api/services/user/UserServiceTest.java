package com.ajudabem.api.services.user;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.auth.ForgotPasswordRequestDTO;
import com.ajudabem.api.dto.auth.LoginRequestDTO;
import com.ajudabem.api.dto.auth.RegisterRequestDTO;
import com.ajudabem.api.dto.auth.ResetPasswordRequestDTO;
import com.ajudabem.api.dto.auth.ResponseDTO;
import com.ajudabem.api.dto.auth.VerifyCodeRequestDTO;
import com.ajudabem.api.dto.auth.VerifyCodeResponseDTO;
import com.ajudabem.api.dto.user.UpdateUserRequestDTO;
import com.ajudabem.api.dto.user.UserResponseDTO;
import com.ajudabem.api.exceptions.CpfAlreadyExistsException;
import com.ajudabem.api.exceptions.EmailAlreadyExistsException;
import com.ajudabem.api.exceptions.InvalidPasswordException;
import com.ajudabem.api.exceptions.InvalidResetTokenException;
import com.ajudabem.api.exceptions.InvalidVerificationCodeException;
import com.ajudabem.api.exceptions.PasswordMismatchException;
import com.ajudabem.api.exceptions.UserAlreadyDeletedException;
import com.ajudabem.api.exceptions.UserNotFoundException;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.mappers.UserMapper;
import com.ajudabem.api.repositories.UserRepository;
import jakarta.mail.Session;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    private static final LocalDate BIRTH_DATE = LocalDate.of(2000, 5, 10);

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

    @Mock
    private JavaMailSender mailSender;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(userService, "mailFrom", "no-reply@ajudabem.com");
    }

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
        RegisterRequestDTO dto = new RegisterRequestDTO("Jane Doe", "jane@example.com", "11999999999", "529.982.247-25", BIRTH_DATE, "secret123", true);

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
                        && user.getCpf().equals("52998224725")
                        && user.getBirth_date().equals(BIRTH_DATE)
        ));
    }

    @Test
    void register_shouldThrowCpfAlreadyExistsException_whenCpfAlreadyUsed() {
        RegisterRequestDTO dto = new RegisterRequestDTO("Jane Doe", "jane@example.com", "11999999999", "529.982.247-25", BIRTH_DATE, "secret123", true);
        User other = existingUser();
        other.setId(2L);

        when(repository.findByEmail(dto.email())).thenReturn(Optional.empty());
        when(repository.findByCpf("52998224725")).thenReturn(Optional.of(other));

        assertThatThrownBy(() -> userService.register(dto))
                .isInstanceOf(CpfAlreadyExistsException.class)
                .hasMessage("CPF is using");

        verify(repository, never()).save(any());
    }

    @Test
    void register_shouldThrowEmailAlreadyExistsException_whenEmailAlreadyUsed() {
        RegisterRequestDTO dto = new RegisterRequestDTO("Jane Doe", "jane@example.com", "11999999999", "529.982.247-25", BIRTH_DATE, "secret123", true);

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
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO("New Name", null, null, null, null);
        UserResponseDTO expected = mock(UserResponseDTO.class);

        when(currentUserService.get()).thenReturn(user);
        when(mapper.toResponse(user)).thenReturn(expected);

        UserResponseDTO result = userService.updateCurrentUser(dto);

        verify(mapper).updateEntity(dto, user);
        verify(repository).save(user);
        assertThat(result).isEqualTo(expected);
    }

    @Test
    void updateCurrentUser_shouldStoreTheCpfDigitsOnly() {
        User user = existingUser();
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO(null, null, null, "529.982.247-25", null);

        when(currentUserService.get()).thenReturn(user);
        when(repository.findByCpf("52998224725")).thenReturn(Optional.empty());

        userService.updateCurrentUser(dto);

        assertThat(user.getCpf()).isEqualTo("52998224725");
        verify(repository).save(user);
    }

    @Test
    void updateCurrentUser_shouldAcceptTheUsersOwnCpf() {
        User user = existingUser();
        user.setCpf("52998224725");
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO(null, null, null, "52998224725", null);

        when(currentUserService.get()).thenReturn(user);
        when(repository.findByCpf("52998224725")).thenReturn(Optional.of(user));

        userService.updateCurrentUser(dto);

        verify(repository).save(user);
    }

    @Test
    void updateCurrentUser_shouldThrowCpfAlreadyExistsException_whenAnotherUserHasTheCpf() {
        User user = existingUser();
        User other = existingUser();
        other.setId(2L);
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO(null, null, null, "529.982.247-25", null);

        when(currentUserService.get()).thenReturn(user);
        when(repository.findByCpf("52998224725")).thenReturn(Optional.of(other));

        assertThatThrownBy(() -> userService.updateCurrentUser(dto))
                .isInstanceOf(CpfAlreadyExistsException.class);

        verify(repository, never()).save(any());
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

    @Test
    void forgotPassword_shouldGenerateAndStoreAVerificationCode_whenEmailExists() {
        User user = existingUser();
        ForgotPasswordRequestDTO dto = new ForgotPasswordRequestDTO("jane@example.com");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));
        when(mailSender.createMimeMessage()).thenReturn(new MimeMessage((Session) null));

        userService.forgotPassword(dto);

        assertThat(user.getResetPasswordCode()).hasSize(4);
        assertThat(user.getResetPasswordCodeExpiresAt()).isAfter(LocalDateTime.now());
        verify(repository).save(user);
        verify(mailSender).send(any(MimeMessage.class));
    }

    @Test
    void buildVerificationCodeEmailHtml_shouldRenderEachDigitIntoItsOwnPlaceholder() {
        String html = userService.buildVerificationCodeEmailHtml("4827");

        assertThat(html)
                .contains(">4<", ">8<", ">2<", ">7<")
                .doesNotContain("{{");
    }

    @Test
    void forgotPassword_shouldThrowUserNotFoundException_whenEmailDoesNotExist() {
        ForgotPasswordRequestDTO dto = new ForgotPasswordRequestDTO("missing@example.com");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.forgotPassword(dto))
                .isInstanceOf(UserNotFoundException.class);
    }

    @Test
    void verifyCode_shouldReturnResetTokenAndClearCode_whenCodeIsValid() {
        User user = existingUser();
        user.setResetPasswordCode("1234");
        user.setResetPasswordCodeExpiresAt(LocalDateTime.now().plusMinutes(5));

        VerifyCodeRequestDTO dto = new VerifyCodeRequestDTO("jane@example.com", "1234");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));

        VerifyCodeResponseDTO result = userService.verifyCode(dto);

        assertThat(result.resetToken()).isNotBlank();
        assertThat(user.getResetPasswordCode()).isNull();
        assertThat(user.getResetPasswordToken()).isEqualTo(result.resetToken());
        assertThat(user.getResetPasswordTokenExpiresAt()).isAfter(LocalDateTime.now());
        verify(repository).save(user);
    }

    @Test
    void verifyCode_shouldThrowInvalidVerificationCodeException_whenCodeDoesNotMatch() {
        User user = existingUser();
        user.setResetPasswordCode("1234");
        user.setResetPasswordCodeExpiresAt(LocalDateTime.now().plusMinutes(5));

        VerifyCodeRequestDTO dto = new VerifyCodeRequestDTO("jane@example.com", "9999");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> userService.verifyCode(dto))
                .isInstanceOf(InvalidVerificationCodeException.class);
    }

    @Test
    void verifyCode_shouldThrowInvalidVerificationCodeException_whenCodeIsExpired() {
        User user = existingUser();
        user.setResetPasswordCode("1234");
        user.setResetPasswordCodeExpiresAt(LocalDateTime.now().minusMinutes(1));

        VerifyCodeRequestDTO dto = new VerifyCodeRequestDTO("jane@example.com", "1234");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> userService.verifyCode(dto))
                .isInstanceOf(InvalidVerificationCodeException.class);
    }

    @Test
    void resetPassword_shouldUpdatePasswordAndClearToken_whenTokenIsValidAndPasswordsMatch() {
        User user = existingUser();
        user.setResetPasswordToken("valid-token");
        user.setResetPasswordTokenExpiresAt(LocalDateTime.now().plusMinutes(5));

        ResetPasswordRequestDTO dto = new ResetPasswordRequestDTO(
                "jane@example.com", "valid-token", "newPassword123", "newPassword123");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));
        when(passwordEncoder.encode(dto.password())).thenReturn("new-hashed-password");

        userService.resetPassword(dto);

        assertThat(user.getPassword()).isEqualTo("new-hashed-password");
        assertThat(user.getResetPasswordToken()).isNull();
        verify(repository).save(user);
    }

    @Test
    void resetPassword_shouldThrowInvalidResetTokenException_whenTokenDoesNotMatch() {
        User user = existingUser();
        user.setResetPasswordToken("valid-token");
        user.setResetPasswordTokenExpiresAt(LocalDateTime.now().plusMinutes(5));

        ResetPasswordRequestDTO dto = new ResetPasswordRequestDTO(
                "jane@example.com", "wrong-token", "newPassword123", "newPassword123");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> userService.resetPassword(dto))
                .isInstanceOf(InvalidResetTokenException.class);

        verify(repository, never()).save(any());
    }

    @Test
    void resetPassword_shouldThrowPasswordMismatchException_whenPasswordsDoNotMatch() {
        User user = existingUser();
        user.setResetPasswordToken("valid-token");
        user.setResetPasswordTokenExpiresAt(LocalDateTime.now().plusMinutes(5));

        ResetPasswordRequestDTO dto = new ResetPasswordRequestDTO(
                "jane@example.com", "valid-token", "newPassword123", "somethingElse");

        when(repository.findByEmail(dto.email())).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> userService.resetPassword(dto))
                .isInstanceOf(PasswordMismatchException.class);

        verify(repository, never()).save(any());
    }
}

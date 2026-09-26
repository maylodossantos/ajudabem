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
import com.ajudabem.api.mappers.UserMapper;
import com.ajudabem.api.repositories.UserRepository;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.infra.validation.CpfValidator;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.time.Year;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int VERIFICATION_CODE_EXPIRATION_MINUTES = 10;
    private static final int RESET_TOKEN_EXPIRATION_MINUTES = 10;
    private static final String VERIFICATION_CODE_EMAIL_TEMPLATE = readTemplate("mail/verification-code-email.html");

    private final UserRepository repository;
    private final UserMapper mapper;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;
    private final CurrentUserService currentUserService;
    private final JavaMailSender mailSender;

    @Value("${api.mail.from}")
    private String mailFrom;

    public ResponseDTO register(RegisterRequestDTO dto) {

        if (repository.findByEmail(dto.email()).isPresent()) {
            throw new EmailAlreadyExistsException("Email is using");
        }

        String cpf = CpfValidator.digitsOnly(dto.cpf());
        requireCpfAvailable(cpf, null);

        User newUser = new User();

        newUser.setPassword(passwordEncoder.encode(dto.password()));
        newUser.setEmail(dto.email());
        newUser.setPhone(dto.phone());
        newUser.setName(dto.name());
        newUser.setCpf(cpf);
        newUser.setBirth_date(dto.birthDate());
        newUser.setRole(UserRole.USER);
        newUser.setLast_login_at(LocalDateTime.now());
        newUser.setTermsAcceptedAt(LocalDateTime.now());
        this.repository.save(newUser);

        String token = this.tokenService.generateToken(newUser);
        return new ResponseDTO(newUser.getName(), token);
    }

    public ResponseDTO login(LoginRequestDTO dto) {

        User user = findUserByEmail(dto.email());

        if (!passwordEncoder.matches(dto.password(), user.getPassword())) {
            throw new InvalidPasswordException("Invalid password");
        }

        String token = this.tokenService.generateToken(user);

        user.setLast_login_at(LocalDateTime.now());
        this.repository.save(user);

        return new ResponseDTO(user.getName(), token);
    }

    public UserResponseDTO getCurrentUser() {

        User user = currentUserService.get();

        return mapper.toResponse(user);
    }

    public UserResponseDTO updateCurrentUser(UpdateUserRequestDTO dto) {

        User user = currentUserService.get();

        mapper.updateEntity(dto, user);

        if (dto.cpf() != null) {
            String cpf = CpfValidator.digitsOnly(dto.cpf());
            requireCpfAvailable(cpf, user.getId());
            user.setCpf(cpf);
        }

        repository.save(user);

        return mapper.toResponse(user);
    }

    public void forgotPassword(ForgotPasswordRequestDTO dto) {

        User user = findUserByEmail(dto.email());

        String code = generateVerificationCode();

        user.setResetPasswordCode(code);
        user.setResetPasswordCodeExpiresAt(LocalDateTime.now().plusMinutes(VERIFICATION_CODE_EXPIRATION_MINUTES));
        repository.save(user);

        sendVerificationCodeEmail(user.getEmail(), code);
    }

    private void sendVerificationCodeEmail(String email, String code) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, StandardCharsets.UTF_8.name());

            helper.setFrom(mailFrom);
            helper.setTo(email);
            helper.setSubject("Confirme seu acesso - AjudaBem");
            helper.setText(
                    "Seu código de verificação é: " + code +
                    "\n\nEle expira em " + VERIFICATION_CODE_EXPIRATION_MINUTES + " minutos." +
                    "\n\nNão compartilhe este código com ninguém." +
                    "\nSe você não solicitou este código, pode ignorar este e-mail com segurança.",
                    buildVerificationCodeEmailHtml(code)
            );

            mailSender.send(mimeMessage);
        } catch (MessagingException exception) {
            throw new RuntimeException("Failed to send verification code email", exception);
        }
    }

    String buildVerificationCodeEmailHtml(String code) {
        String html = VERIFICATION_CODE_EMAIL_TEMPLATE
                .replace("{{EXPIRATION_MINUTES}}", String.valueOf(VERIFICATION_CODE_EXPIRATION_MINUTES))
                .replace("{{YEAR}}", String.valueOf(Year.now().getValue()));

        for (int i = 0; i < code.length(); i++) {
            html = html.replace("{{CODE_" + (i + 1) + "}}", String.valueOf(code.charAt(i)));
        }

        return html;
    }

    private static String readTemplate(String classpathLocation) {
        try {
            return new ClassPathResource(classpathLocation).getContentAsString(StandardCharsets.UTF_8);
        } catch (IOException exception) {
            throw new UncheckedIOException(exception);
        }
    }

    public VerifyCodeResponseDTO verifyCode(VerifyCodeRequestDTO dto) {

        User user = findUserByEmail(dto.email());

        boolean codeIsValid = user.getResetPasswordCode() != null
                && user.getResetPasswordCode().equals(dto.code())
                && user.getResetPasswordCodeExpiresAt() != null
                && user.getResetPasswordCodeExpiresAt().isAfter(LocalDateTime.now());

        if (!codeIsValid) {
            throw new InvalidVerificationCodeException("Invalid or expired verification code");
        }

        String resetToken = UUID.randomUUID().toString();

        user.setResetPasswordCode(null);
        user.setResetPasswordCodeExpiresAt(null);
        user.setResetPasswordToken(resetToken);
        user.setResetPasswordTokenExpiresAt(LocalDateTime.now().plusMinutes(RESET_TOKEN_EXPIRATION_MINUTES));
        repository.save(user);

        return new VerifyCodeResponseDTO(resetToken);
    }

    public void resetPassword(ResetPasswordRequestDTO dto) {

        User user = findUserByEmail(dto.email());

        boolean tokenIsValid = user.getResetPasswordToken() != null
                && user.getResetPasswordToken().equals(dto.resetToken())
                && user.getResetPasswordTokenExpiresAt() != null
                && user.getResetPasswordTokenExpiresAt().isAfter(LocalDateTime.now());

        if (!tokenIsValid) {
            throw new InvalidResetTokenException("Invalid or expired reset token");
        }

        if (!dto.password().equals(dto.confirmPassword())) {
            throw new PasswordMismatchException("Passwords do not match");
        }

        user.setPassword(passwordEncoder.encode(dto.password()));
        user.setResetPasswordToken(null);
        user.setResetPasswordTokenExpiresAt(null);
        repository.save(user);
    }

    private String generateVerificationCode() {
        return String.format("%04d", RANDOM.nextInt(10000));
    }

    public void deleteMe() {
        User user = currentUserService.get();

        if(user.getDeleted()) {
            throw new UserAlreadyDeletedException("User already deleted");
        }

        user.softDelete();
        repository.save(user);
    }

    private User findUserByEmail(String email) {
        return repository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found"));
    }

    /** {@code ownerId} is the user allowed to already have it (on update), or null. */
    private void requireCpfAvailable(String cpf, Long ownerId) {
        repository.findByCpf(cpf)
                .filter(existing -> !existing.getId().equals(ownerId))
                .ifPresent(existing -> {
                    throw new CpfAlreadyExistsException("CPF is using");
                });
    }
}

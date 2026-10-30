package com.ajudabem.api.services.user;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.auth.ForgotPasswordRequestDTO;
import com.ajudabem.api.repositories.UserRepository;
import com.icegreen.greenmail.junit5.GreenMailExtension;
import com.icegreen.greenmail.util.GreenMailUtil;
import com.icegreen.greenmail.util.ServerSetupTest;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class ForgotPasswordEmailIntegrationTest {

    @RegisterExtension
    static GreenMailExtension greenMail = new GreenMailExtension(ServerSetupTest.SMTP);

    @DynamicPropertySource
    static void mailProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.mail.port", () -> ServerSetupTest.SMTP.getPort());
    }

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    void forgotPassword_sendsARealEmailContainingTheVerificationCode() throws Exception {
        User user = new User();
        user.setName("Jane Doe");
        user.setEmail("jane.doe@example.com");
        user.setPassword("hashed-password");
        user.setPhone("49999990000");
        user.setRole(UserRole.USER);
        userRepository.save(user);

        userService.forgotPassword(new ForgotPasswordRequestDTO("jane.doe@example.com"));

        MimeMessage[] receivedMessages = greenMail.getReceivedMessages();
        assertThat(receivedMessages).hasSize(1);

        MimeMessage message = receivedMessages[0];
        assertThat(message.getAllRecipients()[0].toString()).isEqualTo("jane.doe@example.com");
        assertThat(message.getSubject()).isEqualTo("Confirme seu acesso - AjudaBem");

        Matcher codeInEmail = Pattern.compile(": (\\d{4})\\b").matcher(GreenMailUtil.getBody(message));
        assertThat(codeInEmail.find()).isTrue();
        String code = codeInEmail.group(1);

        String storedCode = userRepository.findByEmail("jane.doe@example.com")
                .orElseThrow()
                .getResetPasswordCode();
        assertThat(storedCode).isNotEqualTo(code);
        assertThat(passwordEncoder.matches(code, storedCode)).isTrue();
    }
}

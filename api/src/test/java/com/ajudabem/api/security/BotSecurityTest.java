package com.ajudabem.api.security;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.icegreen.greenmail.junit5.GreenMailExtension;
import com.icegreen.greenmail.util.ServerSetupTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Segurança: bots (força bruta, flood e rate limit)")
class BotSecurityTest extends SecurityTestSupport {

    private static final int REQUESTS_PER_IP = 20;

    @RegisterExtension
    static GreenMailExtension greenMail = new GreenMailExtension(ServerSetupTest.SMTP);

    @DynamicPropertySource
    static void mailProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.mail.port", () -> ServerSetupTest.SMTP.getPort());
    }

    @Autowired
    private PasswordEncoder passwordEncoder;

    private User userWithPassword(String email, String password) {
        User user = saveUser(email, UserRole.USER);
        user.setPassword(passwordEncoder.encode(password));
        return userRepository.save(user);
    }

    private int login(String ip, String email, String password) throws Exception {
        return mockMvc.perform(post("/auth/login").with(fromIp(ip))
                        .contentType(MediaType.APPLICATION_JSON).content(loginBody(email, password)))
                .andReturn().getResponse().getStatus();
    }

    private int verifyCode(String email, String code) throws Exception {
        return mockMvc.perform(post("/auth/verify-code").with(fromIp(newIp()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email + "\",\"code\":\"" + code + "\"}"))
                .andReturn().getResponse().getStatus();
    }

    @Test
    @DisplayName("Força bruta de senha: após 5 erros a conta bloqueia, mesmo vindo de IPs diferentes")
    void passwordBruteForceIsBlockedPerAccount() throws Exception {
        userWithPassword("bot.bruteforce@example.com", "SenhaCerta#1");

        for (int attempt = 1; attempt <= 5; attempt++) {
            assertThat(login(newIp(), "bot.bruteforce@example.com", "chute" + attempt)).isEqualTo(401);
        }

        assertThat(login(newIp(), "bot.bruteforce@example.com", "chute6")).isEqualTo(429);
        assertThat(login(newIp(), "bot.bruteforce@example.com", "SenhaCerta#1"))
                .as("nem a senha certa entra enquanto a conta está bloqueada")
                .isEqualTo(429);
    }

    @Test
    @DisplayName("Login certo zera o contador de erros (usuário legítimo não fica preso)")
    void successfulLoginResetsTheFailureCounter() throws Exception {
        userWithPassword("bot.legit@example.com", "SenhaCerta#1");

        for (int attempt = 1; attempt <= 4; attempt++) {
            assertThat(login(newIp(), "bot.legit@example.com", "errada")).isEqualTo(401);
        }
        assertThat(login(newIp(), "bot.legit@example.com", "SenhaCerta#1")).isEqualTo(200);
        assertThat(login(newIp(), "bot.legit@example.com", "errada")).isEqualTo(401);
    }

    @Test
    @DisplayName("Rate limit por IP: a requisição 21 no mesmo minuto recebe 429 com Retry-After")
    void tooManyRequestsFromTheSameIpAreThrottled() throws Exception {
        String botIp = newIp();

        for (int request = 1; request <= REQUESTS_PER_IP; request++) {
            assertThat(login(botIp, "bot.flood" + request + "@example.com", "x")).isNotEqualTo(429);
        }

        mockMvc.perform(post("/auth/login").with(fromIp(botIp))
                        .contentType(MediaType.APPLICATION_JSON).content(loginBody("bot.flood@example.com", "x")))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().exists("Retry-After"));

        assertThat(login(newIp(), "bot.flood@example.com", "x")).as("outro IP não é afetado").isNotEqualTo(429);
    }

    @Test
    @DisplayName("Rate limit não é burlado trocando o cabeçalho X-Forwarded-For")
    void spoofingXForwardedForDoesNotBypassTheLimit() throws Exception {
        String botIp = newIp();

        for (int request = 1; request <= REQUESTS_PER_IP + 1; request++) {
            mockMvc.perform(post("/auth/register").with(fromIp(botIp))
                    .header("X-Forwarded-For", "203.0.113." + request)
                    .contentType(MediaType.APPLICATION_JSON).content("{}"));
        }

        mockMvc.perform(post("/auth/register").with(fromIp(botIp))
                        .header("X-Forwarded-For", "198.51.100.77")
                        .contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isTooManyRequests());
    }

    @Test
    @DisplayName("Cadastro em massa: bot não cria contas sem limite a partir do mesmo IP")
    void massRegistrationFromOneIpIsThrottled() throws Exception {
        String botIp = newIp();
        int created = 0;
        int throttled = 0;

        for (int request = 1; request <= REQUESTS_PER_IP + 5; request++) {
            int status = mockMvc.perform(post("/auth/register").with(fromIp(botIp))
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(registerBody("bot.fake" + request + "@example.com", "Senha#123")))
                    .andReturn().getResponse().getStatus();
            if (status == 200) created++;
            if (status == 429) throttled++;
        }

        assertThat(created).isEqualTo(REQUESTS_PER_IP);
        assertThat(throttled).isEqualTo(5);
    }

    @Test
    @DisplayName("Força bruta do código de 4 dígitos: após 5 erros o código é invalidado")
    void verificationCodeBruteForceInvalidatesTheCode() throws Exception {
        User user = saveUser("bot.code@example.com", UserRole.USER);
        user.setResetPasswordCode(passwordEncoder.encode("4321"));
        user.setResetPasswordCodeExpiresAt(LocalDateTime.now().plusMinutes(10));
        userRepository.save(user);

        for (int code = 0; code < 5; code++) {
            assertThat(verifyCode("bot.code@example.com", String.format("%04d", code))).isEqualTo(401);
        }

        assertThat(verifyCode("bot.code@example.com", "4321"))
                .as("o código certo não vale mais depois da força bruta")
                .isEqualTo(429);
        assertThat(userRepository.findByEmail("bot.code@example.com").orElseThrow().getResetPasswordCode()).isNull();
    }

    @Test
    @DisplayName("Flood de e-mails de recuperação: no máximo 3 códigos por conta a cada 15 minutos")
    void forgotPasswordEmailFloodIsLimited() throws Exception {
        saveUser("bot.mailflood@example.com", UserRole.USER);

        for (int request = 1; request <= 3; request++) {
            mockMvc.perform(post("/auth/forgot-password").with(fromIp(newIp()))
                            .contentType(MediaType.APPLICATION_JSON).content("{\"email\":\"bot.mailflood@example.com\"}"))
                    .andExpect(status().isOk());
        }

        mockMvc.perform(post("/auth/forgot-password").with(fromIp(newIp()))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"email\":\"bot.mailflood@example.com\"}"))
                .andExpect(status().isTooManyRequests());

        assertThat(greenMail.getReceivedMessages()).hasSize(3);
    }
}

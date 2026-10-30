package com.ajudabem.api.security;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.icegreen.greenmail.junit5.GreenMailExtension;
import com.icegreen.greenmail.util.GreenMailUtil;
import com.icegreen.greenmail.util.ServerSetupTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Segurança: criptografia, senhas e tokens")
class CryptographySecurityTest extends SecurityTestSupport {

    private static final Pattern BCRYPT = Pattern.compile("^\\$2[aby]\\$\\d{2}\\$[./A-Za-z0-9]{53}$");
    private static final String ISSUER = "login-auth-api";

    @RegisterExtension
    static GreenMailExtension greenMail = new GreenMailExtension(ServerSetupTest.SMTP);

    @DynamicPropertySource
    static void mailProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.mail.port", () -> ServerSetupTest.SMTP.getPort());
    }

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${api.security.token.secret}")
    private String jwtSecret;

    private String postJson(String path, String body, int expectedStatus) throws Exception {
        return mockMvc.perform(post(path).with(fromIp(newIp()))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().is(expectedStatus))
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
    }

    private String verificationCodeFromLastEmail() {
        String body = GreenMailUtil.getBody(greenMail.getReceivedMessages()[greenMail.getReceivedMessages().length - 1]);
        Matcher matcher = Pattern.compile(": (\\d{4})\\b").matcher(body);
        assertThat(matcher.find()).isTrue();
        return matcher.group(1);
    }

    @Test
    @DisplayName("Senha é salva com BCrypt (hash com salt), nunca em texto puro")
    void passwordIsStoredAsASaltedBcryptHash() throws Exception {
        postJson("/auth/register", registerBody("crypto.hash.a@example.com", "MinhaSenha#2026"), 200);
        postJson("/auth/register", registerBody("crypto.hash.b@example.com", "MinhaSenha#2026"), 200);

        String hashA = userRepository.findByEmail("crypto.hash.a@example.com").orElseThrow().getPassword();
        String hashB = userRepository.findByEmail("crypto.hash.b@example.com").orElseThrow().getPassword();

        assertThat(hashA).matches(BCRYPT).doesNotContain("MinhaSenha");
        assertThat(hashB).matches(BCRYPT);
        assertThat(hashA).as("mesma senha deve gerar hashes diferentes (salt)").isNotEqualTo(hashB);
        assertThat(passwordEncoder.matches("MinhaSenha#2026", hashA)).isTrue();
    }

    @Test
    @DisplayName("Nenhuma resposta da API devolve a senha ou o hash")
    void responsesNeverExposeThePasswordOrItsHash() throws Exception {
        String registered = postJson("/auth/register", registerBody("crypto.leak@example.com", "OutraSenha#2026"), 200);
        assertThat(registered).doesNotContain("OutraSenha", "$2a$", "password");

        String token = objectMapper.readTree(registered).get("token").asText();
        mockMvc.perform(get("/user/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(content().string(not(containsString("$2a$"))))
                .andExpect(content().string(not(containsString("password"))))
                .andExpect(content().string(not(containsString("resetPassword"))));
    }

    @Test
    @DisplayName("Login: senha errada é recusada, a certa é aceita")
    void loginOnlyAcceptsTheRightPassword() throws Exception {
        postJson("/auth/register", registerBody("crypto.login@example.com", "Correta#2026"), 200);

        postJson("/auth/login", loginBody("crypto.login@example.com", "correta#2026"), 401);
        postJson("/auth/login", loginBody("crypto.login@example.com", "Correta#2026"), 200);
    }

    @Test
    @DisplayName("Recuperação de senha: código e token ficam só como hash no banco e o token é de uso único")
    void passwordResetSecretsAreHashedAndSingleUse() throws Exception {
        postJson("/auth/register", registerBody("crypto.reset@example.com", "Antiga#2026"), 200);

        postJson("/auth/forgot-password", "{\"email\":\"crypto.reset@example.com\"}", 200);
        String code = verificationCodeFromLastEmail();
        String storedCode = userRepository.findByEmail("crypto.reset@example.com").orElseThrow().getResetPasswordCode();
        assertThat(storedCode).isNotEqualTo(code).matches(BCRYPT);

        String verified = postJson("/auth/verify-code",
                "{\"email\":\"crypto.reset@example.com\",\"code\":\"" + code + "\"}", 200);
        String resetToken = objectMapper.readTree(verified).get("resetToken").asText();
        String storedToken = userRepository.findByEmail("crypto.reset@example.com").orElseThrow().getResetPasswordToken();
        assertThat(storedToken).isNotEqualTo(resetToken).matches(BCRYPT);

        String reset = """
                {"email":"crypto.reset@example.com","resetToken":"%s","password":"Nova#2026","confirmPassword":"Nova#2026"}
                """.formatted(resetToken);
        postJson("/auth/reset-password", reset, 200);
        postJson("/auth/reset-password", reset, 401);

        postJson("/auth/login", loginBody("crypto.reset@example.com", "Antiga#2026"), 401);
        postJson("/auth/login", loginBody("crypto.reset@example.com", "Nova#2026"), 200);
    }

    @Test
    @DisplayName("JWT assinado com outra chave é recusado")
    void jwtSignedWithAnotherSecretIsRejected() throws Exception {
        User admin = saveUser("crypto.jwt.forged@example.com", UserRole.ADMIN);
        String forged = JWT.create().withIssuer(ISSUER).withSubject(admin.getEmail())
                .withExpiresAt(Instant.now().plus(1, ChronoUnit.HOURS))
                .sign(Algorithm.HMAC256("chave-adivinhada"));

        mockMvc.perform(get("/user/me").header("Authorization", "Bearer " + forged))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("JWT sem assinatura (alg: none) é recusado")
    void unsignedJwtIsRejected() throws Exception {
        User admin = saveUser("crypto.jwt.none@example.com", UserRole.ADMIN);
        String unsigned = JWT.create().withIssuer(ISSUER).withSubject(admin.getEmail())
                .withExpiresAt(Instant.now().plus(1, ChronoUnit.HOURS))
                .sign(Algorithm.none());

        mockMvc.perform(get("/user/me").header("Authorization", "Bearer " + unsigned))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("JWT expirado é recusado")
    void expiredJwtIsRejected() throws Exception {
        User user = saveUser("crypto.jwt.expired@example.com", UserRole.USER);
        String expired = JWT.create().withIssuer(ISSUER).withSubject(user.getEmail())
                .withExpiresAt(Instant.now().minus(1, ChronoUnit.MINUTES))
                .sign(Algorithm.HMAC256(jwtSecret));

        mockMvc.perform(get("/user/me").header("Authorization", "Bearer " + expired))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("JWT adulterado (troca do e-mail no payload mantendo a assinatura) é recusado")
    void tamperedJwtIsRejected() throws Exception {
        User user = saveUser("crypto.jwt.user@example.com", UserRole.USER);
        User admin = saveUser("crypto.jwt.admin@example.com", UserRole.ADMIN);
        String[] parts = tokenService.generateToken(user).split("\\.");
        String payload = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8)
                .replace(user.getEmail(), admin.getEmail());
        String tampered = parts[0] + "." + Base64.getUrlEncoder().withoutPadding()
                .encodeToString(payload.getBytes(StandardCharsets.UTF_8)) + "." + parts[2];

        mockMvc.perform(get("/user/me").header("Authorization", "Bearer " + tampered))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("Token de conta excluída deixa de funcionar (401, sem erro 500)")
    void tokenOfADeletedAccountStopsWorking() throws Exception {
        User user = saveUser("crypto.jwt.deleted@example.com", UserRole.USER);
        String token = bearer(user);

        mockMvc.perform(delete("/user/me").header("Authorization", token))
                .andExpect(status().is2xxSuccessful());
        mockMvc.perform(get("/user/me").header("Authorization", token))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }
}

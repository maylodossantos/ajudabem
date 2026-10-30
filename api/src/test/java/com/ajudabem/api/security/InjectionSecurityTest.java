package com.ajudabem.api.security;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.http.MediaType;

import java.time.LocalDateTime;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Segurança: injeção de código (SQL, XSS, cabeçalho de e-mail, parâmetros)")
class InjectionSecurityTest extends SecurityTestSupport {

    private static final String SQL_PAYLOAD = "Robert'); DROP TABLE users;--";
    private static final String XSS_PAYLOAD = "<script>alert('xss')</script>";

    private void saveOrganization(String tradeName, String cnpj) {
        Organization organization = new Organization();
        organization.setOwner(saveUser("owner." + cnpj + "@example.com", UserRole.USER));
        organization.setTradeName(tradeName);
        organization.setCnpj(cnpj);
        organization.setStatus(OrganizationStatus.PENDING);
        organization.setSubmittedAt(LocalDateTime.now());
        organizationRepository.save(organization);
    }

    @ParameterizedTest(name = "e-mail = {0}")
    @ValueSource(strings = {"' OR '1'='1", "' OR 1=1 --", "admin@example.com' --", "\" OR \"\"=\"", "'; DROP TABLE users; --"})
    @DisplayName("SQL injection no login não autentica ninguém")
    void sqlInjectionInLoginDoesNotAuthenticate(String payload) throws Exception {
        if (userRepository.findByEmail("injection.admin@example.com").isEmpty()) {
            saveUser("injection.admin@example.com", UserRole.ADMIN);
        }

        String response = mockMvc.perform(post("/auth/login").with(fromIp(newIp()))
                        .contentType(MediaType.APPLICATION_JSON).content(loginBody(payload, "' OR '1'='1")))
                .andExpect(status().is4xxClientError())
                .andReturn().getResponse().getContentAsString();

        assertThat(response).doesNotContain("token");
        assertThat(userRepository.findByEmail("injection.admin@example.com")).isPresent();
    }

    @Test
    @DisplayName("SQL injection no perfil é salva como texto e não executa nada no banco")
    void sqlInjectionInProfileIsStoredAsPlainText() throws Exception {
        User user = saveUser("injection.profile@example.com", UserRole.USER);
        long usersBefore = userRepository.count();

        mockMvc.perform(put("/user/me").header("Authorization", bearer(user))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("name", SQL_PAYLOAD))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value(SQL_PAYLOAD));

        assertThat(userRepository.count()).isEqualTo(usersBefore);
        assertThat(userRepository.findById(user.getId()).orElseThrow().getName()).isEqualTo(SQL_PAYLOAD);
    }

    @ParameterizedTest(name = "search = {0}")
    @ValueSource(strings = {"' OR 'a'='a", "%", "_", "%' OR 'x'='x' --"})
    @DisplayName("Busca de ONGs: SQL injection e curingas de LIKE não listam tudo")
    void organizationSearchIsNotInjectable(String payload) throws Exception {
        User admin = saveUser("injection.search.admin." + Math.abs(payload.hashCode()) + "@example.com", UserRole.ADMIN);
        saveOrganization("Casa do Bem", "9100000000" + String.format("%04d", Math.abs(payload.hashCode()) % 10000));

        mockMvc.perform(get("/organization").param("search", payload).header("Authorization", bearer(admin)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @ParameterizedTest(name = "id = {0}")
    @ValueSource(strings = {"1 OR 1=1", "1;DROP TABLE users", "1' --", "../../etc/passwd"})
    @DisplayName("Ids na URL só aceitam números")
    void pathIdsOnlyAcceptNumbers(String payload) throws Exception {
        User user = saveUser("injection.path." + Math.abs(payload.hashCode()) + "@example.com", UserRole.ADMIN);

        int status = mockMvc.perform(get("/assisted-person/{id}", payload).header("Authorization", bearer(user)))
                .andReturn().getResponse().getStatus();

        assertThat(status).isIn(400, 404);
    }

    @Test
    @DisplayName("Tipo de documento da ONG só aceita valores do enum")
    void documentTypeOnlyAcceptsKnownValues() throws Exception {
        User admin = saveUser("injection.doctype@example.com", UserRole.ADMIN);

        mockMvc.perform(get("/organization/1/documents/{type}", "CNPJ_PROOF' OR '1'='1").header("Authorization", bearer(admin)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("XSS: script em notícia volta como dado JSON, com nosniff, nunca como HTML")
    void storedXssIsReturnedAsInertJson() throws Exception {
        User admin = saveUser("injection.xss@example.com", UserRole.ADMIN);
        String created = mockMvc.perform(post("/news").header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("title", XSS_PAYLOAD, "content", XSS_PAYLOAD))))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        mockMvc.perform(get("/news/" + idOf(created)))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(header().string("X-Content-Type-Options", "nosniff"))
                .andExpect(jsonPath("$.title").value(XSS_PAYLOAD));
    }

    @ParameterizedTest(name = "e-mail = {0}")
    @ValueSource(strings = {"vitima@example.com\r\nBcc: atacante@evil.com", "vitima@example.com\nCc:atacante@evil.com",
            "vitima@example.com,atacante@evil.com"})
    @DisplayName("Injeção de cabeçalho no e-mail de recuperação é bloqueada")
    void emailHeaderInjectionIsRejected(String payload) throws Exception {
        mockMvc.perform(post("/auth/forgot-password").with(fromIp(newIp()))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", payload))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.email").exists());
    }
}

package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.repositories.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMultipartHttpServletRequestBuilder;

import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class OrganizationValidationIntegrationTest {

    private static final List<String> ALL_DOCUMENTS =
            List.of("CNPJ_PROOF", "BYLAWS", "BOARD_ELECTION_MINUTES", "RESPONSIBLE_ID");

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TokenService tokenService;

    private User saveUser(String email, UserRole role) {
        User user = new User();
        user.setName(email);
        user.setEmail(email);
        user.setPassword("irrelevant");
        user.setRole(role);
        return userRepository.save(user);
    }

    private String bearer(User user) {
        return "Bearer " + tokenService.generateToken(user);
    }

    private static Map<String, Object> form(String cnpj) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("corporateName", "Associação Amigos dos Rios");
        body.put("tradeName", "Amigos dos Rios");
        body.put("cnpj", cnpj);
        body.put("activityArea", "Meio Ambiente");
        body.put("street", "Rua das Flores");
        body.put("number", "123");
        body.put("neighborhood", "Centro");
        body.put("city", "Cascavel");
        body.put("state", "PR");
        body.put("zipCode", "85800-000");
        body.put("instagram", "@amigosdosrios");
        body.put("acceptedTerms", true);
        body.put("acceptedDataProcessing", true);
        body.put("declaredTruthful", true);
        return body;
    }

    private static MockMultipartFile pdf(String part) {
        return new MockMultipartFile(part, part.toLowerCase() + ".pdf", "application/pdf",
                ("%PDF-1.4 " + part).getBytes(StandardCharsets.US_ASCII));
    }

    private ResultActions submit(User owner, String cnpj, List<String> documents) throws Exception {
        MockMultipartHttpServletRequestBuilder request = multipart("/organization/me");
        request.file(new MockMultipartFile("data", "", MediaType.APPLICATION_JSON_VALUE,
                objectMapper.writeValueAsBytes(form(cnpj))));
        documents.forEach(part -> request.file(pdf(part)));

        return mockMvc.perform(request.header("Authorization", bearer(owner)));
    }

    private long idOf(ResultActions result) throws Exception {
        return objectMapper.readTree(result.andReturn().getResponse().getContentAsString()).get("id").asLong();
    }

    @Test
    void fullFlow_userSubmitsPdfsAdminApprovesAndTheUserBecomesAnOng() throws Exception {
        User owner = saveUser("rios.owner@example.com", UserRole.USER);
        User admin = saveUser("rios.admin@example.com", UserRole.ADMIN);

        mockMvc.perform(get("/organization/me").header("Authorization", bearer(owner)))
                .andExpect(status().isNotFound());

        long id = idOf(submit(owner, "44.555.666/0001-81", ALL_DOCUMENTS)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.cnpj").value("44555666000181"))
                .andExpect(jsonPath("$.documents", hasSize(4)))
                .andExpect(jsonPath("$.documents[0].fileName").isNotEmpty())
                .andExpect(content().string(not(containsString("http")))));

        submit(owner, "44.555.666/0001-81", ALL_DOCUMENTS).andExpect(status().isConflict());

        mockMvc.perform(get("/organization").param("status", "PENDING").param("search", "rios")
                        .header("Authorization", bearer(admin)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].tradeName").value("Amigos dos Rios"));

        mockMvc.perform(post("/organization/" + id + "/approve").header("Authorization", bearer(owner)))
                .andExpect(status().isForbidden());

        mockMvc.perform(post("/organization/" + id + "/approve").header("Authorization", bearer(admin)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APPROVED"));

        mockMvc.perform(get("/user/me").header("Authorization", bearer(owner)))
                .andExpect(jsonPath("$.role").value("USER_ONG"));

        mockMvc.perform(post("/organization/" + id + "/reject")
                        .header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"reason\":\"OTHER\"}"))
                .andExpect(status().isConflict());
    }

    @Test
    void documents_shouldOnlyBeDownloadableByTheAdminAndTheOwner() throws Exception {
        User owner = saveUser("docs.owner@example.com", UserRole.USER);
        User admin = saveUser("docs.admin@example.com", UserRole.ADMIN);
        User stranger = saveUser("docs.stranger@example.com", UserRole.USER_ONG);
        long id = idOf(submit(owner, "11.222.333/0001-81", ALL_DOCUMENTS).andExpect(status().isOk()));
        String path = "/organization/" + id + "/documents/BYLAWS";

        mockMvc.perform(get(path)).andExpect(status().isUnauthorized());
        mockMvc.perform(get(path).header("Authorization", bearer(stranger))).andExpect(status().isForbidden());

        mockMvc.perform(get(path).header("Authorization", bearer(admin)))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_PDF))
                .andExpect(header().string("Cache-Control", "private, no-store"))
                .andExpect(header().string("Content-Disposition", containsString("bylaws.pdf")))
                .andExpect(content().bytes("%PDF-1.4 BYLAWS".getBytes(StandardCharsets.US_ASCII)));

        mockMvc.perform(get(path).header("Authorization", bearer(owner))).andExpect(status().isOk());
    }

    @Test
    void reject_shouldTellTheOwnerWhyAndWhenTheyCanTryAgain() throws Exception {
        User owner = saveUser("esperanca.owner@example.com", UserRole.USER);
        User admin = saveUser("esperanca.admin@example.com", UserRole.ADMIN);
        long id = idOf(submit(owner, "77.888.999/0001-81", ALL_DOCUMENTS).andExpect(status().isOk()));

        mockMvc.perform(post("/organization/" + id + "/reject")
                        .header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"reason\":\"ILLEGIBLE_DOCUMENTS\",\"note\":\"Estatuto ilegível\"}"))
                .andExpect(status().isOk());

        mockMvc.perform(get("/organization/me").header("Authorization", bearer(owner)))
                .andExpect(jsonPath("$.status").value("REJECTED"))
                .andExpect(jsonPath("$.rejectionReason").value("ILLEGIBLE_DOCUMENTS"))
                .andExpect(jsonPath("$.rejectionNote").value("Estatuto ilegível"))
                .andExpect(jsonPath("$.resubmitAvailableAt").isNotEmpty());

        submit(owner, "77.888.999/0001-81", List.of()).andExpect(status().isConflict());
    }

    @Test
    void submit_shouldRefuseMissingDocumentsNonPdfsAndAnInvalidCnpj() throws Exception {
        User owner = saveUser("incomplete.owner@example.com", UserRole.USER);

        submit(owner, "12.345.678/0001-95", List.of("CNPJ_PROOF", "BYLAWS"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("All required documents must be sent"));

        MockMultipartHttpServletRequestBuilder withImage = multipart("/organization/me");
        withImage.file(new MockMultipartFile("data", "", MediaType.APPLICATION_JSON_VALUE,
                objectMapper.writeValueAsBytes(form("12.345.678/0001-95"))));
        ALL_DOCUMENTS.stream().filter(part -> !part.equals("BYLAWS")).forEach(part -> withImage.file(pdf(part)));
        withImage.file(new MockMultipartFile("BYLAWS", "foto.jpg", "image/jpeg", new byte[]{(byte) 0xFF, (byte) 0xD8}));
        mockMvc.perform(withImage.header("Authorization", bearer(owner)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Documents must be PDF files up to 10 MB"));

        submit(owner, "12.345.678/0001-90", ALL_DOCUMENTS)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.cnpj").value("CNPJ inválido"));
    }

    @Test
    void list_shouldOnlyBeAvailableToAdmins() throws Exception {
        User ong = saveUser("list.ong@example.com", UserRole.USER_ONG);

        mockMvc.perform(get("/organization").header("Authorization", bearer(ong)))
                .andExpect(status().isForbidden());
    }
}

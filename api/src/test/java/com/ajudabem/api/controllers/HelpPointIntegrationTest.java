package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasItem;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class HelpPointIntegrationTest {

    private static final String BODY = """
            {"name":"Albergue Municipal Esperança","description":"Abrigo noturno",
             "organizationType":"MUNICIPAL_SHELTER","services":["SHELTER","OVERNIGHT","FOOD"],
             "street":"R. Rio Borá","number":"1916","neighborhood":"Brasmadeira","city":"Cascavel",
             "state":"PR","zipCode":"85814-508","phone":"(11) 3942-7810",
             "openingHours":[{"dayOfWeek":"MONDAY","opensAt":"18:00","closesAt":"07:00"}],
             "notes":"Entrada das 18h às 21h"}""";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TokenService tokenService;

    private String bearer(String email, UserRole role) {
        User user = new User();
        user.setName(email);
        user.setEmail(email);
        user.setPassword("irrelevant");
        user.setRole(role);
        return "Bearer " + tokenService.generateToken(userRepository.save(user));
    }

    @Test
    void adminCreates_andAnyoneReadsWithoutLoggingIn() throws Exception {
        String admin = bearer("help.admin@example.com", UserRole.ADMIN);

        mockMvc.perform(post("/help-point").header("Authorization", admin)
                        .contentType(MediaType.APPLICATION_JSON).content(BODY))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.source").value("MANUAL"))
                .andExpect(jsonPath("$.zipCode").value("85814508"))
                .andExpect(jsonPath("$.openingHours[0].closesAt").value("07:00:00"));

        mockMvc.perform(get("/help-point"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].name", hasItem("Albergue Municipal Esperança")));
    }

    @Test
    void writes_shouldBeRefusedForEveryoneButAdmins() throws Exception {
        String ong = bearer("help.ong@example.com", UserRole.USER_ONG);

        mockMvc.perform(post("/help-point").contentType(MediaType.APPLICATION_JSON).content(BODY))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(post("/help-point").header("Authorization", ong)
                        .contentType(MediaType.APPLICATION_JSON).content(BODY))
                .andExpect(status().isForbidden());
        mockMvc.perform(delete("/help-point/1").header("Authorization", ong))
                .andExpect(status().isForbidden());
    }

    @Test
    void create_shouldExplainMissingFieldsInPortuguese() throws Exception {
        String admin = bearer("help.validation@example.com", UserRole.ADMIN);

        mockMvc.perform(post("/help-point").header("Authorization", admin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"\",\"services\":[],\"state\":\"Parana\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.name").value("Nome é obrigatório"))
                .andExpect(jsonPath("$.errors.services").value("Selecione ao menos um serviço oferecido"))
                .andExpect(jsonPath("$.errors.state").value("Estado deve ser a sigla da UF"));
    }
}

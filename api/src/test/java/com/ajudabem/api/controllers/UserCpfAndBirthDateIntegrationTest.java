package com.ajudabem.api.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import java.util.LinkedHashMap;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class UserCpfAndBirthDateIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private ResultActions register(String email, String cpf, String birthDate) throws Exception {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("name", "Jane Doe");
        body.put("email", email);
        body.put("phone", "45999999999");
        body.put("cpf", cpf);
        body.put("birthDate", birthDate);
        body.put("password", "secret123");
        body.put("acceptedTerms", true);

        return mockMvc.perform(post("/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(body)));
    }

    private String tokenOf(ResultActions registration) throws Exception {
        String json = registration.andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(json).get("token").asText();
    }

    @Test
    void register_shouldStoreTheCpfDigitsAndTheBirthDate() throws Exception {
        String token = tokenOf(register("cpf.owner@example.com", "390.533.447-05", "2000-05-10")
                .andExpect(status().isOk()));

        mockMvc.perform(get("/user/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cpf").value("39053344705"))
                .andExpect(jsonPath("$.birth_date").value("2000-05-10"));
    }

    @Test
    void register_shouldRejectACpfAlreadyInUse_evenWithADifferentMask() throws Exception {
        register("first.cpf@example.com", "111.444.777-35", "1990-01-01").andExpect(status().isOk());

        register("second.cpf@example.com", "11144477735", "1990-01-01")
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("CPF is using"));
    }

    @Test
    void register_shouldExplainInvalidCpfAndFutureBirthDateInPortuguese() throws Exception {
        register("invalid.cpf@example.com", "123.456.789-00", "2999-01-01")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.cpf").value("CPF inválido"))
                .andExpect(jsonPath("$.errors.birthDate").value("Data de nascimento deve estar no passado"));
    }

    @Test
    void register_shouldRequireCpfAndBirthDate() throws Exception {
        register("missing.cpf@example.com", null, null)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.cpf").value("CPF é obrigatório"))
                .andExpect(jsonPath("$.errors.birthDate").value("Data de nascimento é obrigatória"));
    }

    @Test
    void updateMe_shouldChangeCpfAndBirthDate() throws Exception {
        String token = tokenOf(register("cpf.editor@example.com", "529.982.247-25", "1985-03-02")
                .andExpect(status().isOk()));

        mockMvc.perform(put("/user/me")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"cpf\":\"871.113.790-80\",\"birthDate\":\"1985-03-20\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cpf").value("87111379080"))
                .andExpect(jsonPath("$.birth_date").value("1985-03-20"));
    }
}

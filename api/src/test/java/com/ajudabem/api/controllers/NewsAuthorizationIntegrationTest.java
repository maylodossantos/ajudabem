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
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class NewsAuthorizationIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TokenService tokenService;

    @Autowired
    private ObjectMapper objectMapper;

    private String tokenFor(String email, UserRole role) {
        User user = new User();
        user.setName("Test User");
        user.setEmail(email);
        user.setPassword("irrelevant");
        user.setRole(role);
        userRepository.save(user);

        return tokenService.generateToken(user);
    }

    private String newsBody() throws Exception {
        return objectMapper.writeValueAsString(Map.of(
                "title", "Title",
                "subtitle", "Subtitle",
                "content", "Content",
                "cover_image", "cover.png"
        ));
    }

    @Test
    void createNews_shouldReturn403_whenAuthorIsARegularUser() throws Exception {
        String token = tokenFor("regular@example.com", UserRole.USER);

        mockMvc.perform(
                post("/news")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(newsBody())
        ).andExpect(status().isForbidden());
    }

    @Test
    void createNews_shouldReturn403_whenAuthorIsAnOng() throws Exception {
        String token = tokenFor("ong@example.com", UserRole.USER_ONG);

        mockMvc.perform(
                post("/news")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(newsBody())
        ).andExpect(status().isForbidden());
    }

    @Test
    void createNews_shouldReturn200_whenAuthorIsAnAdmin() throws Exception {
        String token = tokenFor("admin@example.com", UserRole.ADMIN);

        mockMvc.perform(
                post("/news")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(newsBody())
        ).andExpect(status().isOk());
    }

    @Test
    void getAllNews_shouldReturn200_withoutAuthentication() throws Exception {
        mockMvc.perform(get("/news")).andExpect(status().isOk());
    }
}

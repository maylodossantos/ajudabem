package com.ajudabem.api.infra.security;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class CurrentUserResolutionTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TokenService tokenService;

    @Test
    void getMe_shouldResolveTheAuthenticatedUserFromARealJwt() throws Exception {
        User user = new User();
        user.setName("Diagnostic User");
        user.setEmail("diagnostic@example.com");
        user.setPassword("irrelevant");
        user.setRole(UserRole.USER);
        userRepository.save(user);

        String token = tokenService.generateToken(user);

        mockMvc.perform(
                get("/user/me")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
        ).andExpect(status().isOk());
    }
}

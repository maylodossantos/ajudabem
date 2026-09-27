package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.infra.security.TokenService;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class AssistedPersonOwnershipIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AssistedPersonRepository assistedPersonRepository;

    @Autowired
    private TokenService tokenService;

    private User saveUser(String email) {
        return saveUser(email, UserRole.USER);
    }

    private User saveUser(String email, UserRole role) {
        User user = new User();
        user.setName(email);
        user.setEmail(email);
        user.setPassword("irrelevant");
        user.setRole(role);
        return userRepository.save(user);
    }

    private Long savePerson(String fullName, User author) {
        AssistedPerson person = new AssistedPerson();
        person.setFull_name(fullName);
        person.setAuthor(author);
        return assistedPersonRepository.save(person).getId();
    }

    private String bearer(User user) {
        return "Bearer " + tokenService.generateToken(user);
    }

    private static final String UPDATE_BODY = """
            {"full_name":"Changed","age":30,"gender":"MALE","tagIds":[],"notes":"x",
             "street":"s","number":"1","neighborhood":"n","city":"c","state":"st",
             "zip_code":"z","country":"BR"}""";

    @Test
    void byId_shouldOnlyLetTheAuthorChangeButAlsoLetAdminsAndOngsView() throws Exception {
        User author = saveUser("byid.author@example.com");
        User stranger = saveUser("byid.stranger@example.com");
        User ong = saveUser("byid.ong@example.com", UserRole.USER_ONG);
        User admin = saveUser("byid.admin@example.com", UserRole.ADMIN);
        Long id = savePerson("Maria", author);
        String path = "/assisted-person/" + id;

        mockMvc.perform(get(path).header("Authorization", bearer(stranger))).andExpect(status().isForbidden());
        mockMvc.perform(put(path).header("Authorization", bearer(stranger))
                .contentType(MediaType.APPLICATION_JSON).content(UPDATE_BODY)).andExpect(status().isForbidden());
        mockMvc.perform(delete(path).header("Authorization", bearer(stranger))).andExpect(status().isForbidden());

        mockMvc.perform(get(path).header("Authorization", bearer(ong))).andExpect(status().isOk());
        mockMvc.perform(get(path).header("Authorization", bearer(admin))).andExpect(status().isOk());
        mockMvc.perform(delete(path).header("Authorization", bearer(admin))).andExpect(status().isForbidden());

        mockMvc.perform(get(path).header("Authorization", bearer(author)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.full_name").value("Maria"));
        mockMvc.perform(put(path).header("Authorization", bearer(author))
                        .contentType(MediaType.APPLICATION_JSON).content(UPDATE_BODY))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.full_name").value("Changed"));
        mockMvc.perform(delete(path).header("Authorization", bearer(author))).andExpect(status().is2xxSuccessful());
    }

    @Test
    void getAll_shouldOnlyReturnPeopleRegisteredByTheTokenUser() throws Exception {
        User owner = saveUser("owner@example.com");
        User someoneElse = saveUser("someone.else@example.com");
        savePerson("Maria", owner);
        savePerson("João", someoneElse);

        mockMvc.perform(
                get("/assisted-person")
                        .header("Authorization", "Bearer " + tokenService.generateToken(owner))
        )
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].full_name").value("Maria"));
    }
}

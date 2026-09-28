package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.time.LocalDate;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class NotificationAndImpactIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private AssistedPersonRepository personRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void theAuthorIsNotifiedWhenAnOngAssumesTheCase_andCanMarkItRead() throws Exception {
        User author = saveUser("notify.author@example.com", UserRole.USER);
        User ong = approvedOng("notify.ong@example.com", "90000000000301");
        AssistedPerson person = new AssistedPerson();
        person.setFull_name("Ana Lima");
        person.setAuthor(author);
        Long personId = personRepository.save(person).getId();

        mockMvc.perform(post("/care/" + personId + "/assume").header("Authorization", bearer(ong)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/notification/unread-count").header("Authorization", bearer(author)))
                .andExpect(jsonPath("$.unread").value(1));
        String body = mockMvc.perform(get("/notification").header("Authorization", bearer(author)))
                .andExpect(jsonPath("$[0].type").value("CASE_ASSUMED"))
                .andExpect(jsonPath("$[0].targetId").value(personId))
                .andExpect(jsonPath("$[0].message").value(
                        "A ONG ONG notify.ong@example.com assumiu o atendimento de Ana Lima."))
                .andReturn().getResponse().getContentAsString();
        long id = objectMapper.readTree(body).get(0).get("id").asLong();

        mockMvc.perform(post("/notification/" + id + "/read").header("Authorization", bearer(ong)))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/notification/" + id + "/read").header("Authorization", bearer(author)))
                .andExpect(jsonPath("$.readAt").exists());
        mockMvc.perform(get("/notification/unread-count").header("Authorization", bearer(author)))
                .andExpect(jsonPath("$.unread").value(0));
    }

    @Test
    void aNewCampaignReachesEveryoneButItsOwnOng() throws Exception {
        User reader = saveUser("notify.reader@example.com", UserRole.USER);
        User ong = approvedOng("notify.campaign@example.com", "90000000000302");

        mockMvc.perform(post("/campaign").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"title":"Inverno Solidário","description":"Agasalhos","category":"CLOTHING",
                                 "deadline":"%s"}
                                """.formatted(LocalDate.now().plusDays(5))))
                .andExpect(status().isOk());

        mockMvc.perform(get("/notification").header("Authorization", bearer(reader)))
                .andExpect(jsonPath("$[*].title", hasItem("Nova campanha criada")));
        mockMvc.perform(post("/notification/read-all").header("Authorization", bearer(reader)))
                .andExpect(status().isNoContent());
        mockMvc.perform(get("/notification/unread-count").header("Authorization", bearer(reader)))
                .andExpect(jsonPath("$.unread").value(0));
        mockMvc.perform(get("/notification/unread-count").header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$.unread").value(0));
    }

    @Test
    void impactNumbersAreCountedForThePlatformAndTheOng() throws Exception {
        User author = saveUser("impact.author@example.com", UserRole.USER);
        User ong = approvedOng("impact.ong@example.com", "90000000000303");
        AssistedPerson person = new AssistedPerson();
        person.setFull_name("Pedro");
        person.setAuthor(author);
        Long personId = personRepository.save(person).getId();

        mockMvc.perform(post("/care/" + personId + "/assume").header("Authorization", bearer(ong)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/impact").header("Authorization", bearer(author)))
                .andExpect(jsonPath("$.registered").value(greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$.inCare").value(greaterThanOrEqualTo(1)));
        mockMvc.perform(get("/impact/organization").header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$.peopleHelped").value(1))
                .andExpect(jsonPath("$.volunteers").value(0))
                .andExpect(jsonPath("$.campaignsFinished").value(0));
        mockMvc.perform(get("/impact/organization").header("Authorization", bearer(author)))
                .andExpect(status().isForbidden());
    }

    @Test
    void onlyAdminsManageNeeds() throws Exception {
        User admin = saveUser("tags.admin@example.com", UserRole.ADMIN);
        User user = saveUser("tags.user@example.com", UserRole.USER);

        mockMvc.perform(post("/tag").header("Authorization", bearer(user))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Higiene\"}"))
                .andExpect(status().isForbidden());

        String body = mockMvc.perform(post("/tag").header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Higiene\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        long id = objectMapper.readTree(body).get("id").asLong();

        mockMvc.perform(post("/tag").header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"higiene\"}"))
                .andExpect(status().isConflict());
        mockMvc.perform(put("/tag/" + id).header("Authorization", bearer(admin))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Higiene pessoal\"}"))
                .andExpect(jsonPath("$.name").value("Higiene pessoal"));
        mockMvc.perform(delete("/tag/" + id).header("Authorization", bearer(admin)))
                .andExpect(status().isNoContent());
        mockMvc.perform(get("/tag").header("Authorization", bearer(user)))
                .andExpect(jsonPath("$[?(@.id == " + id + ")]").isEmpty());
    }

    @Test
    void theMapShowsLocatedPeopleToOngsOnly() throws Exception {
        User author = saveUser("map.author@example.com", UserRole.USER);
        User ong = approvedOng("map.ong@example.com", "90000000000304");
        AssistedPerson person = new AssistedPerson();
        person.setFull_name("Carla Mapa");
        person.setAuthor(author);
        person.setLatitude(-24.95);
        person.setLongitude(-53.45);
        personRepository.save(person);

        mockMvc.perform(get("/care/map").header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$[*].fullName", hasItem("Carla Mapa")));
        mockMvc.perform(get("/care/map").header("Authorization", bearer(author)))
                .andExpect(status().isForbidden());
    }
}

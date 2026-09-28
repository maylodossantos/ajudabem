package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.time.LocalDate;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class InitiativeIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private ObjectMapper objectMapper;

    private static String campaign(String title) {
        return """
                {"title":"%s","donationInfo":"PIX 123","subtitle":"100 cestas",
                 "description":"Levar alimento a familias","category":"FOOD",
                 "goalAmount":1000.50,"deadline":"%s"}
                """.formatted(title, LocalDate.now().plusDays(10));
    }

    private static String action(int volunteersNeeded, String start, String end) {
        return """
                {"title":"Distribuição de alimentos","date":"%s","startTime":"%s","endTime":"%s",
                 "volunteersNeeded":%d,"street":"Praça Wilson Joffre","city":"Cascavel","state":"pr",
                 "zipCode":"85810-000","description":"Entrega de marmitas","tasks":"Organizar\\nDistribuir"}
                """.formatted(LocalDate.now().plusDays(3), start, end, volunteersNeeded);
    }

    private long idOf(String body) throws Exception {
        JsonNode node = objectMapper.readTree(body);
        return node.get("id").asLong();
    }

    @Test
    void campaignsArePublishedByApprovedOngsAndListedPublicly() throws Exception {
        User ong = approvedOng("campaign.ong@example.com", "90000000000201");
        User otherOng = approvedOng("campaign.other@example.com", "90000000000202");
        User user = saveUser("campaign.user@example.com", UserRole.USER);

        mockMvc.perform(post("/campaign").header("Authorization", bearer(user))
                        .contentType(MediaType.APPLICATION_JSON).content(campaign("Cestas")))
                .andExpect(status().isForbidden());

        String created = mockMvc.perform(post("/campaign").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON).content(campaign("Cestas básicas")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andExpect(jsonPath("$.organization.tradeName").value("ONG campaign.ong@example.com"))
                .andReturn().getResponse().getContentAsString();
        long id = idOf(created);

        mockMvc.perform(get("/campaign"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].title", hasItem("Cestas básicas")));
        mockMvc.perform(get("/campaign/" + id))
                .andExpect(jsonPath("$.goalAmount").value(1000.50));
        mockMvc.perform(get("/campaign/mine"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(get("/campaign/mine").header("Authorization", bearer(otherOng)))
                .andExpect(jsonPath("$[*].title", not(hasItem("Cestas básicas"))));

        mockMvc.perform(put("/campaign/" + id).header("Authorization", bearer(otherOng))
                        .contentType(MediaType.APPLICATION_JSON).content(campaign("Outra")))
                .andExpect(status().isForbidden());
        mockMvc.perform(put("/campaign/" + id).header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON).content(campaign("Cestas para 200 famílias")))
                .andExpect(jsonPath("$.title").value("Cestas para 200 famílias"));

        mockMvc.perform(post("/campaign/" + id + "/finish").header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$.status").value("FINISHED"));
        mockMvc.perform(get("/campaign"))
                .andExpect(jsonPath("$[*].title", not(hasItem("Cestas para 200 famílias"))));
        mockMvc.perform(post("/campaign/" + id + "/finish").header("Authorization", bearer(ong)))
                .andExpect(status().isConflict());
    }

    @Test
    void volunteersApplyTheOngAcceptsAndOnlyAcceptedOnesSeeTheContact() throws Exception {
        User ong = approvedOng("action.ong@example.com", "90000000000203");
        User maria = saveUser("action.maria@example.com", UserRole.USER);
        User joao = saveUser("action.joao@example.com", UserRole.USER);

        mockMvc.perform(post("/volunteer-action").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON).content(action(1, "21:00", "18:00")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.timeRangeValid").value("O término deve ser depois do início"));

        String created = mockMvc.perform(post("/volunteer-action").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON).content(action(1, "18:00", "21:00")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.state").value("PR"))
                .andExpect(jsonPath("$.zipCode").value("85810000"))
                .andReturn().getResponse().getContentAsString();
        String path = "/volunteer-action/" + idOf(created);

        mockMvc.perform(post(path + "/apply").header("Authorization", bearer(ong)))
                .andExpect(status().isForbidden());

        mockMvc.perform(post(path + "/apply").header("Authorization", bearer(maria)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.myApplication").value("PENDING"))
                .andExpect(jsonPath("$.contact").doesNotExist());
        mockMvc.perform(post(path + "/apply").header("Authorization", bearer(maria)))
                .andExpect(status().isConflict());
        mockMvc.perform(post(path + "/apply").header("Authorization", bearer(joao)))
                .andExpect(status().isOk());

        String volunteers = mockMvc.perform(get(path + "/volunteers").header("Authorization", bearer(ong)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("action.maria@example.com"))
                .andReturn().getResponse().getContentAsString();
        long mariaApplication = objectMapper.readTree(volunteers).get(0).get("id").asLong();
        long joaoApplication = objectMapper.readTree(volunteers).get(1).get("id").asLong();

        mockMvc.perform(get(path + "/volunteers").header("Authorization", bearer(maria)))
                .andExpect(status().isForbidden());

        mockMvc.perform(post(path + "/volunteers/" + mariaApplication + "/accept")
                        .header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$.status").value("ACCEPTED"));
        mockMvc.perform(post(path + "/volunteers/" + joaoApplication + "/accept")
                        .header("Authorization", bearer(ong)))
                .andExpect(status().isConflict());

        mockMvc.perform(get(path).header("Authorization", bearer(maria)))
                .andExpect(jsonPath("$.myApplication").value("ACCEPTED"))
                .andExpect(jsonPath("$.acceptedCount").value(1))
                .andExpect(jsonPath("$.contact.email").value("action.ong@example.com"));
        mockMvc.perform(get(path).header("Authorization", bearer(joao)))
                .andExpect(jsonPath("$.myApplication").value("PENDING"))
                .andExpect(jsonPath("$.contact").doesNotExist());

        mockMvc.perform(delete(path + "/apply").header("Authorization", bearer(maria)))
                .andExpect(jsonPath("$.myApplication").doesNotExist())
                .andExpect(jsonPath("$.acceptedCount").value(0));
        mockMvc.perform(post(path + "/apply").header("Authorization", bearer(maria)))
                .andExpect(jsonPath("$.myApplication").value("PENDING"));

        mockMvc.perform(post(path + "/finish").header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$.status").value("FINISHED"));
        mockMvc.perform(get("/volunteer-action").header("Authorization", bearer(joao)))
                .andExpect(jsonPath("$[*].id", not(hasItem((int) idOf(created)))));
    }
}

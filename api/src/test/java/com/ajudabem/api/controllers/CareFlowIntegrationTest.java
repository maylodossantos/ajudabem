package com.ajudabem.api.controllers;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.TagRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.time.LocalDateTime;

import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class CareFlowIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private AssistedPersonRepository personRepository;

    @Autowired
    private TagRepository tagRepository;

    private Long saveTag(String name) {
        Tag tag = new Tag();
        tag.setName(name);
        return tagRepository.save(tag).getId();
    }

    private Long savePerson(String name, User author) {
        AssistedPerson person = new AssistedPerson();
        person.setFull_name(name);
        person.setAuthor(author);
        return personRepository.save(person).getId();
    }

    private static String record(String status, String extra) {
        return "{\"status\":\"" + status + "\",\"occurredAt\":\"" + LocalDateTime.now().minusHours(1).withNano(0)
                + "\"" + extra + "}";
    }

    @Test
    void ongAssumesRecordsAndFinishes_andTheVolunteerSeesTheProgress() throws Exception {
        User volunteer = saveUser("care.volunteer@example.com", UserRole.USER);
        User ong = approvedOng("care.ong@example.com", "90000000000101");
        User otherOng = approvedOng("care.other@example.com", "90000000000102");
        Long personId = savePerson("Maria Silva", volunteer);
        String path = "/care/" + personId;
        String tagIds = "[" + saveTag("Alimentação") + "," + saveTag("Moradia") + "]";

        mockMvc.perform(get("/care/nominated").header("Authorization", bearer(volunteer)))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/care/nominated").header("Authorization", bearer(ong)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[*].fullName", hasItem("Maria Silva")));

        mockMvc.perform(post(path + "/assume").header("Authorization", bearer(ong)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.careStatus").value("IN_CARE"));
        mockMvc.perform(post(path + "/assume").header("Authorization", bearer(otherOng)))
                .andExpect(status().isConflict());

        mockMvc.perform(post(path + "/records").header("Authorization", bearer(otherOng))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(record("STARTED", "")))
                .andExpect(status().isForbidden());

        mockMvc.perform(post(path + "/records").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(record("STARTED", ",\"situation\":\"Sem abrigo\",\"tagIds\":" + tagIds)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.records", hasSize(1)))
                .andExpect(jsonPath("$.records[0].number").value(1))
                .andExpect(jsonPath("$.person.tags", hasSize(2)));

        mockMvc.perform(post(path + "/records").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(record("FINISHED", "")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.finishReasonGiven").value("Informe o motivo da finalização"));

        mockMvc.perform(post(path + "/records").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(record("FINISHED", ",\"finishReason\":\"HELPED\",\"summary\":\"Acolhida\"")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.person.careStatus").value("FINISHED"))
                .andExpect(jsonPath("$.records[1].number").value(2));

        mockMvc.perform(post(path + "/records").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(record("IN_PROGRESS", "")))
                .andExpect(status().isConflict());

        mockMvc.perform(get("/care/cases").header("Authorization", bearer(ong)))
                .andExpect(jsonPath("$[*].fullName", hasItem("Maria Silva")));
        mockMvc.perform(get("/care/cases").header("Authorization", bearer(otherOng)))
                .andExpect(jsonPath("$[*].fullName", not(hasItem("Maria Silva"))));

        mockMvc.perform(get("/assisted-person").header("Authorization", bearer(volunteer)))
                .andExpect(jsonPath("$[0].careStatus").value("FINISHED"))
                .andExpect(jsonPath("$[0].organization.tradeName").value("ONG care.ong@example.com"));
    }

    @Test
    void anOngStillUnderReviewCannotTakeCases() throws Exception {
        User pending = saveUser("care.pending@example.com", UserRole.USER_ONG);
        Long personId = savePerson("João", saveUser("care.author@example.com", UserRole.USER));

        mockMvc.perform(post("/care/" + personId + "/assume").header("Authorization", bearer(pending)))
                .andExpect(status().isForbidden());
    }
}

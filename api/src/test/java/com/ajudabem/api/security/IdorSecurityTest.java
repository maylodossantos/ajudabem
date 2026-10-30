package com.ajudabem.api.security;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.notification.Notification;
import com.ajudabem.api.domains.notification.NotificationType;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.repositories.NotificationRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Segurança: IDOR e controle de acesso")
class IdorSecurityTest extends SecurityTestSupport {

    private static final String PERSON_BODY = """
            {"full_name":"Alterado pelo atacante","age":30,"gender":"MALE","tagIds":[],"notes":"x",
             "street":"s","number":"1","neighborhood":"n","city":"c","state":"st",
             "zip_code":"z","country":"BR"}""";

    @Autowired
    private AssistedPersonRepository assistedPersonRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    private Long savePerson(String fullName, User author) {
        AssistedPerson person = new AssistedPerson();
        person.setFull_name(fullName);
        person.setAuthor(author);
        return assistedPersonRepository.save(person).getId();
    }

    private static String campaign(String title) {
        return """
                {"title":"%s","donationInfo":"PIX 123","subtitle":"100 cestas",
                 "description":"Levar alimento a familias","category":"FOOD",
                 "goalAmount":1000.50,"deadline":"%s"}
                """.formatted(title, LocalDate.now().plusDays(10));
    }

    private static String action() {
        return """
                {"title":"Distribuição de alimentos","date":"%s","startTime":"18:00","endTime":"21:00",
                 "volunteersNeeded":2,"street":"Praça Wilson Joffre","city":"Cascavel","state":"pr",
                 "zipCode":"85810-000","description":"Entrega de marmitas","tasks":"Distribuir"}
                """.formatted(LocalDate.now().plusDays(3));
    }

    @Test
    @DisplayName("Pessoa assistida: outro usuário não lê, altera nem exclui trocando o id na URL")
    void assistedPersonCannotBeReachedByChangingTheIdInTheUrl() throws Exception {
        User victim = saveUser("idor.person.victim@example.com", UserRole.USER);
        User attacker = saveUser("idor.person.attacker@example.com", UserRole.USER);
        Long id = savePerson("Maria da Vítima", victim);
        String path = "/assisted-person/" + id;

        mockMvc.perform(get(path).header("Authorization", bearer(attacker)))
                .andExpect(status().isForbidden());
        mockMvc.perform(put(path).header("Authorization", bearer(attacker))
                        .contentType(MediaType.APPLICATION_JSON).content(PERSON_BODY))
                .andExpect(status().isForbidden());
        mockMvc.perform(delete(path).header("Authorization", bearer(attacker)))
                .andExpect(status().isForbidden());

        AssistedPerson stored = assistedPersonRepository.findById(id).orElseThrow();
        assertThat(stored.getFull_name()).isEqualTo("Maria da Vítima");
        assertThat(stored.getDeleted()).isFalse();
    }

    @Test
    @DisplayName("Pessoa assistida: enumerar ids sequenciais não vaza cadastro de ninguém")
    void enumeratingSequentialIdsLeaksNothing() throws Exception {
        User victim = saveUser("idor.enum.victim@example.com", UserRole.USER);
        User attacker = saveUser("idor.enum.attacker@example.com", UserRole.USER);
        Long lastId = savePerson("Pessoa sigilosa", victim);

        for (long id = 1; id <= lastId + 3; id++) {
            int status = mockMvc.perform(get("/assisted-person/" + id).header("Authorization", bearer(attacker)))
                    .andReturn().getResponse().getStatus();
            assertThat(status).as("GET /assisted-person/" + id).isIn(403, 404);
        }

        mockMvc.perform(get("/assisted-person").header("Authorization", bearer(attacker)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(0)));
    }

    @Test
    @DisplayName("Notificação: não dá para marcar como lida a notificação de outra pessoa")
    void notificationOfSomeoneElseCannotBeMarkedAsRead() throws Exception {
        User victim = saveUser("idor.notification.victim@example.com", UserRole.USER);
        User attacker = saveUser("idor.notification.attacker@example.com", UserRole.USER);
        Notification notification = new Notification();
        notification.setRecipient(victim);
        notification.setType(NotificationType.CASE_ASSUMED);
        notification.setTitle("Privada");
        notification.setMessage("Só da vítima");
        Long id = notificationRepository.save(notification).getId();

        mockMvc.perform(post("/notification/" + id + "/read").header("Authorization", bearer(attacker)))
                .andExpect(status().isNotFound());
        mockMvc.perform(get("/notification").header("Authorization", bearer(attacker)))
                .andExpect(jsonPath("$", hasSize(0)));

        assertThat(notificationRepository.findById(id).orElseThrow().getReadAt()).isNull();
    }

    @Test
    @DisplayName("ONG: dados e documentos sigilosos só para o dono e o admin")
    void organizationDataAndDocumentsAreOnlyForTheOwnerAndAdmins() throws Exception {
        User owner = saveUser("idor.org.owner@example.com", UserRole.USER);
        User attacker = saveUser("idor.org.attacker@example.com", UserRole.USER);
        Organization organization = new Organization();
        organization.setOwner(owner);
        organization.setTradeName("ONG Sigilosa");
        organization.setCnpj("90000000000901");
        organization.setStatus(OrganizationStatus.PENDING);
        organization.setSubmittedAt(LocalDateTime.now());
        Long id = organizationRepository.save(organization).getId();

        mockMvc.perform(get("/organization/" + id).header("Authorization", bearer(attacker)))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/organization/" + id + "/documents/RESPONSIBLE_ID").header("Authorization", bearer(attacker)))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/organization").header("Authorization", bearer(attacker)))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/organization/" + id).header("Authorization", bearer(owner)))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("ONG: usuário comum não aprova a própria ONG (escalada de privilégio)")
    void userCannotApproveTheirOwnOrganization() throws Exception {
        User owner = saveUser("idor.approve.owner@example.com", UserRole.USER);
        Organization organization = new Organization();
        organization.setOwner(owner);
        organization.setTradeName("ONG Apressada");
        organization.setCnpj("90000000000902");
        organization.setStatus(OrganizationStatus.PENDING);
        organization.setSubmittedAt(LocalDateTime.now());
        Long id = organizationRepository.save(organization).getId();

        mockMvc.perform(post("/organization/" + id + "/approve").header("Authorization", bearer(owner)))
                .andExpect(status().isForbidden());

        assertThat(organizationRepository.findById(id).orElseThrow().getStatus()).isEqualTo(OrganizationStatus.PENDING);
        assertThat(userRepository.findById(owner.getId()).orElseThrow().getRole()).isEqualTo(UserRole.USER);
    }

    @Test
    @DisplayName("Campanha: outra ONG não edita nem finaliza a campanha alheia")
    void campaignOfAnotherOngCannotBeChanged() throws Exception {
        User ong = approvedOng("idor.campaign.ong@example.com", "90000000000903");
        User otherOng = approvedOng("idor.campaign.other@example.com", "90000000000904");
        String created = mockMvc.perform(post("/campaign").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON).content(campaign("Cestas")))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        String path = "/campaign/" + idOf(created);

        mockMvc.perform(put(path).header("Authorization", bearer(otherOng))
                        .contentType(MediaType.APPLICATION_JSON).content(campaign("Golpe")))
                .andExpect(status().isForbidden());
        mockMvc.perform(post(path + "/finish").header("Authorization", bearer(otherOng)))
                .andExpect(status().isForbidden());

        mockMvc.perform(get(path))
                .andExpect(jsonPath("$.title").value("Cestas"))
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    @DisplayName("Ação voluntária: outra ONG não edita, não vê os voluntários nem aceita candidaturas")
    void volunteerActionOfAnotherOngCannotBeManaged() throws Exception {
        User ong = approvedOng("idor.action.ong@example.com", "90000000000905");
        User otherOng = approvedOng("idor.action.other@example.com", "90000000000906");
        User volunteer = saveUser("idor.action.volunteer@example.com", UserRole.USER);
        String created = mockMvc.perform(post("/volunteer-action").header("Authorization", bearer(ong))
                        .contentType(MediaType.APPLICATION_JSON).content(action()))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        String path = "/volunteer-action/" + idOf(created);
        mockMvc.perform(post(path + "/apply").header("Authorization", bearer(volunteer)))
                .andExpect(status().isOk());
        String volunteers = mockMvc.perform(get(path + "/volunteers").header("Authorization", bearer(ong)))
                .andReturn().getResponse().getContentAsString();
        long applicationId = objectMapper.readTree(volunteers).get(0).get("id").asLong();

        mockMvc.perform(put(path).header("Authorization", bearer(otherOng))
                        .contentType(MediaType.APPLICATION_JSON).content(action()))
                .andExpect(status().isForbidden());
        mockMvc.perform(get(path + "/volunteers").header("Authorization", bearer(otherOng)))
                .andExpect(status().isForbidden());
        mockMvc.perform(get(path + "/volunteers").header("Authorization", bearer(volunteer)))
                .andExpect(status().isForbidden());
        mockMvc.perform(post(path + "/volunteers/" + applicationId + "/accept").header("Authorization", bearer(otherOng)))
                .andExpect(status().isForbidden());
        mockMvc.perform(post(path + "/finish").header("Authorization", bearer(otherOng)))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Atendimento: só a ONG responsável registra andamento; usuário comum não vê o caso")
    void careCaseIsOnlyHandledByTheOngInCharge() throws Exception {
        User author = saveUser("idor.care.author@example.com", UserRole.USER);
        User ong = approvedOng("idor.care.ong@example.com", "90000000000907");
        User otherOng = approvedOng("idor.care.other@example.com", "90000000000908");
        String path = "/care/" + savePerson("Caso sigiloso", author);
        mockMvc.perform(post(path + "/assume").header("Authorization", bearer(ong)))
                .andExpect(status().isOk());

        mockMvc.perform(post(path + "/records").header("Authorization", bearer(otherOng))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"STARTED\",\"occurredAt\":\"" + LocalDateTime.now().minusHours(1).withNano(0) + "\"}"))
                .andExpect(status().isForbidden());
        mockMvc.perform(get(path).header("Authorization", bearer(author)))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("Cadastro: enviar \"role\":\"ADMIN\" no corpo não cria administrador (mass assignment)")
    void registerIgnoresARoleSentInTheBody() throws Exception {
        String body = registerBody("idor.massassign@example.com", "senhaForte123")
                .replace("\"acceptedTerms\":true", "\"acceptedTerms\":true,\"role\":\"ADMIN\"");

        mockMvc.perform(post("/auth/register").with(fromIp(newIp()))
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk());

        assertThat(userRepository.findByEmail("idor.massassign@example.com").orElseThrow().getRole())
                .isEqualTo(UserRole.USER);
    }

    @Test
    @DisplayName("Perfil: PUT /user/me com \"role\":\"ADMIN\" não promove o usuário")
    void updatingTheProfileCannotChangeTheRole() throws Exception {
        User user = saveUser("idor.selfpromote@example.com", UserRole.USER);

        mockMvc.perform(put("/user/me").header("Authorization", bearer(user))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Novo nome\",\"role\":\"ADMIN\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value("USER"));

        assertThat(userRepository.findById(user.getId()).orElseThrow().getRole()).isEqualTo(UserRole.USER);
    }

    @Test
    @DisplayName("Funções de admin: usuário comum não publica notícia nem gerencia necessidades")
    void adminOnlyFeaturesAreForbiddenForRegularUsers() throws Exception {
        User user = saveUser("idor.notadmin@example.com", UserRole.USER);

        mockMvc.perform(post("/news").header("Authorization", bearer(user))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"title\":\"Fake\",\"content\":\"Fake news\"}"))
                .andExpect(status().isForbidden());
        mockMvc.perform(post("/tag").header("Authorization", bearer(user))
                        .contentType(MediaType.APPLICATION_JSON).content("{\"name\":\"Invasão\"}"))
                .andExpect(status().isForbidden());
    }

    @ParameterizedTest(name = "GET {0} sem token -> 401")
    @ValueSource(strings = {"/user/me", "/assisted-person", "/notification", "/organization", "/care/cases",
            "/campaign/mine", "/volunteer-action/mine", "/organization/1/documents/CNPJ_PROOF"})
    @DisplayName("Rotas privadas exigem token")
    void privateRoutesRequireAToken(String path) throws Exception {
        mockMvc.perform(get(path)).andExpect(status().isUnauthorized());
    }
}

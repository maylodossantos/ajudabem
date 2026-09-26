package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.domains.assisted_person.Gender;
import com.ajudabem.api.domains.assisted_person.RiskLevel;
import com.ajudabem.api.domains.assisted_person.Tag;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class RiskTriageServiceTest {

    private MockRestServiceServer ollama;
    private AssistedPersonRepository repository;
    private RiskTriageService service;

    @BeforeEach
    void setUp() {
        RestClient.Builder builder = RestClient.builder().baseUrl("http://ollama");
        ollama = MockRestServiceServer.bindTo(builder).build();
        repository = mock(AssistedPersonRepository.class);
        service = new RiskTriageService(builder.build(), "qwen2.5:3b", new ObjectMapper(), repository);
    }

    private AssistedPerson person() {
        Tag food = new Tag();
        food.setName("Alimentação");
        Tag health = new Tag();
        health.setName("Saúde");

        AssistedPerson person = new AssistedPerson();
        person.setId(7L);
        person.setFull_name("Maria da Silva");
        person.setAge(72);
        person.setGender(Gender.FEMALE);
        person.setStreet("Rua das Flores");
        person.setNumber("123");
        person.setCity("Cascavel");
        person.setNotes("Mora sozinha, está sem remédio para pressão há uma semana.");
        person.setTags(List.of(food, health));
        return person;
    }

    private void ollamaAnswers(String modelContent) {
        String escaped = modelContent.replace("\"", "\\\"");
        ollama.expect(requestTo("http://ollama/api/chat"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withSuccess(
                        "{\"model\":\"qwen2.5:3b\",\"message\":{\"role\":\"assistant\",\"content\":\""
                                + escaped + "\"},\"done\":true}",
                        MediaType.APPLICATION_JSON));
    }

    @Test
    void triage_shouldReturnTheModelsClassification() {
        ollamaAnswers("{\"justification\":\"Idosa sem remédio\",\"riskLevel\":\"HIGH\"}");

        assertThat(service.triage(person())).contains(RiskLevel.HIGH);
        ollama.verify();
    }

    @Test
    void triage_shouldConstrainTheAnswerAndNeverSendNameOrAddress() {
        ollama.expect(requestTo("http://ollama/api/chat"))
                .andExpect(content().string(containsString("\"model\":\"qwen2.5:3b\"")))
                .andExpect(content().string(containsString("\"enum\":[\"LOW\",\"MEDIUM\",\"HIGH\"]")))
                .andExpect(content().string(containsString("sem remédio para pressão")))
                .andExpect(content().string(not(containsString("Maria"))))
                .andExpect(content().string(not(containsString("Rua das Flores"))))
                .andExpect(content().string(not(containsString("Cascavel"))))
                .andRespond(withSuccess(
                        "{\"message\":{\"content\":\"{\\\"justification\\\":\\\"x\\\",\\\"riskLevel\\\":\\\"LOW\\\"}\"}}",
                        MediaType.APPLICATION_JSON));

        service.triage(person());

        ollama.verify();
    }

    @Test
    void triage_shouldGiveUp_whenOllamaFails() {
        ollama.expect(requestTo("http://ollama/api/chat")).andRespond(withServerError());

        assertThat(service.triage(person())).isEmpty();
    }

    @Test
    void triage_shouldGiveUp_whenTheModelAnswersSomethingElse() {
        ollamaAnswers("não sei classificar");

        assertThat(service.triage(person())).isEmpty();
    }

    @Test
    void triagePending_shouldStoreTheLevelOfEachPendingPerson() {
        when(repository.findTop20ByRiskLevelIsNullOrderByCreatedAtAsc()).thenReturn(List.of(person()));
        ollamaAnswers("{\"justification\":\"Idosa sem remédio\",\"riskLevel\":\"HIGH\"}");

        service.triagePending();

        verify(repository).updateRiskLevelIfPending(7L, RiskLevel.HIGH);
    }

    @Test
    void triagePending_shouldLeaveThePersonPending_whenTriageIsUnavailable() {
        when(repository.findTop20ByRiskLevelIsNullOrderByCreatedAtAsc()).thenReturn(List.of(person()));
        ollama.expect(requestTo("http://ollama/api/chat")).andRespond(withServerError());

        service.triagePending();

        verify(repository, never()).updateRiskLevelIfPending(any(), any());
    }
}

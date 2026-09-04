package com.ajudabem.api.system;

import com.ajudabem.api.dto.auth.RegisterRequestDTO;
import com.ajudabem.api.dto.auth.ResponseDTO;
import com.ajudabem.api.dto.news.NewsRequestDTO;
import com.ajudabem.api.dto.news.NewsResponseDTO;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;

import static org.assertj.core.api.Assertions.assertThat;

// System test: drives the whole stack (Controller -> Service -> Repository -> DB, plus the
// real JWT security filter chain) through actual HTTP calls, the way a mobile/frontend client
// would - register an account, then create/read/update/delete a news article with it.
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class NewsSystemTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void userRegistersThenCreatesReadsUpdatesAndDeletesANews() {
        RegisterRequestDTO registerRequest = new RegisterRequestDTO(
                "Ana Voluntária", "ana.voluntaria@example.com", "49999991111", "senha123"
        );
        ResponseDTO registerResponse = restTemplate.postForObject("/auth/register", registerRequest, ResponseDTO.class);

        assertThat(registerResponse).isNotNull();
        assertThat(registerResponse.token()).isNotBlank();

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(registerResponse.token());

        NewsRequestDTO createRequest = new NewsRequestDTO(
                "Mutirão de doações neste sábado", "Traga roupas e alimentos não perecíveis",
                "Texto completo sobre o mutirão.", null
        );
        var createResponse = restTemplate.exchange(
                "/news", HttpMethod.POST, new HttpEntity<>(createRequest, headers), NewsResponseDTO.class);

        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        Long newsId = createResponse.getBody().id();
        assertThat(newsId).isNotNull();
        assertThat(createResponse.getBody().author().name()).isEqualTo("Ana Voluntária");

        var getResponse = restTemplate.exchange(
                "/news/" + newsId, HttpMethod.GET, new HttpEntity<>(headers), NewsResponseDTO.class);

        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody().title()).isEqualTo("Mutirão de doações neste sábado");

        NewsRequestDTO updateRequest = new NewsRequestDTO(
                "Mutirão de doações adiado para domingo", "Traga roupas e alimentos não perecíveis",
                "Texto completo sobre o mutirão.", null
        );
        var updateResponse = restTemplate.exchange(
                "/news/" + newsId, HttpMethod.PUT, new HttpEntity<>(updateRequest, headers), NewsResponseDTO.class);

        assertThat(updateResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(updateResponse.getBody().title()).isEqualTo("Mutirão de doações adiado para domingo");

        var deleteResponse = restTemplate.exchange(
                "/news/" + newsId, HttpMethod.DELETE, new HttpEntity<>(headers), Void.class);

        assertThat(deleteResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void requestWithoutTokenIsRejected() {
        var response = restTemplate.getForEntity("/news", String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }
}

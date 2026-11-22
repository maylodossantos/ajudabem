package com.ajudabem.api.infra;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Component
public class OllamaClient {

    private final RestClient client;
    private final String model;

    @Autowired
    public OllamaClient(@Value("${api.ollama.url}") String baseUrl, @Value("${api.ollama.model}") String model) {
        this(restClient(baseUrl), model);
    }

    public OllamaClient(RestClient client, String model) {
        this.client = client;
        this.model = model;
    }

    public String model() {
        return model;
    }

    public String chat(String systemPrompt, String userMessage, Map<String, Object> responseSchema) {
        ChatResponse response = client.post()
                .uri("/api/chat")
                .body(Map.of(
                        "model", model,
                        "stream", false,
                        "format", responseSchema,
                        "options", Map.of("temperature", 0),
                        "messages", List.of(
                                Map.of("role", "system", "content", systemPrompt),
                                Map.of("role", "user", "content", userMessage)
                        )
                ))
                .retrieve()
                .body(ChatResponse.class);
        if (response == null || response.message() == null) {
            throw new IllegalStateException("Empty response from Ollama");
        }
        return response.message().content();
    }

    private static RestClient restClient(String baseUrl) {
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(
                HttpClient.newBuilder()
                        .version(HttpClient.Version.HTTP_1_1)
                        .connectTimeout(Duration.ofSeconds(2))
                        .build());
        requestFactory.setReadTimeout(Duration.ofMinutes(2));

        return RestClient.builder().baseUrl(baseUrl).requestFactory(requestFactory).build();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record ChatResponse(Message message) {

        @JsonIgnoreProperties(ignoreUnknown = true)
        record Message(String content) {
        }
    }
}

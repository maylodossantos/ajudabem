package com.ajudabem.api.services.assisted_person;

import com.ajudabem.api.domains.assisted_person.AssistedPerson;
import com.ajudabem.api.infra.OllamaClient;
import com.ajudabem.api.repositories.AssistedPersonRepository;
import com.ajudabem.api.services.help_point.GeocodingService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class ApproximateLocationServiceTest {

    private OllamaClient ollama;
    private GeocodingService geocoding;
    private AssistedPersonRepository repository;
    private ApproximateLocationService service;

    @BeforeEach
    void setUp() {
        ollama = mock(OllamaClient.class);
        geocoding = mock(GeocodingService.class);
        repository = mock(AssistedPersonRepository.class);
        service = new ApproximateLocationService(ollama, new ObjectMapper(), geocoding, repository);
    }

    private static AssistedPerson pending() {
        AssistedPerson person = new AssistedPerson();
        person.setId(3L);
        person.setCity("Cascavel");
        person.setState("PR");
        person.setLocationDescription("Fica perto da rodoviária, embaixo da marquise");
        person.setLocationPending(true);
        person.setLatitude(-24.95);
        person.setLongitude(-53.45);
        return person;
    }

    @Test
    void approximate_shouldTryEachSuggestedPlaceUntilOneIsFound() {
        AssistedPerson person = pending();
        when(ollama.chat(anyString(), anyString(), anyMap()))
                .thenReturn("{\"queries\":[\"Rodoviária Velha\",\"Terminal Rodoviário de Cascavel\"]}");
        when(geocoding.search(anyString())).thenReturn(Optional.empty());
        when(geocoding.search("Terminal Rodoviário de Cascavel, Cascavel, PR, Brasil"))
                .thenReturn(Optional.of(new GeocodingService.Coordinates(-24.97, -53.47)));

        service.approximate(person);

        assertThat(person.getLatitude()).isEqualTo(-24.97);
        assertThat(person.getLongitude()).isEqualTo(-53.47);
        assertThat(person.isLocationPending()).isFalse();
        verify(geocoding).search("Rodoviária Velha, Cascavel, PR, Brasil");
        verify(repository).save(person);
    }

    @Test
    void approximate_shouldKeepTheCityCenterWhenNothingIsFound() {
        AssistedPerson person = pending();
        when(ollama.chat(anyString(), anyString(), anyMap())).thenReturn("{\"queries\":[\"Lugar inexistente\"]}");
        when(geocoding.search(anyString())).thenReturn(Optional.empty());

        service.approximate(person);

        assertThat(person.getLatitude()).isEqualTo(-24.95);
        assertThat(person.isLocationPending()).isFalse();
        verify(repository).save(person);
    }

    @Test
    void approximate_shouldRetryLaterWhenTheModelIsOffline() {
        AssistedPerson person = pending();
        when(ollama.chat(anyString(), anyString(), anyMap())).thenThrow(new IllegalStateException("offline"));

        service.approximate(person);

        assertThat(person.isLocationPending()).isTrue();
        verify(repository, never()).save(any());
    }

    @Test
    void describe_shouldWrapTheVolunteerTextAsData() {
        assertThat(ApproximateLocationService.describe(pending()))
                .contains("<place>", "Cidade: Cascavel", "Descrição: Fica perto da rodoviária");
    }
}

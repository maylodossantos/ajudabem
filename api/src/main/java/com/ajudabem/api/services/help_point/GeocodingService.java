package com.ajudabem.api.services.help_point;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.net.http.HttpClient;
import java.time.Duration;
import java.util.Optional;

@Slf4j
@Service
public class GeocodingService {

    private final RestClient nominatim;

    @Autowired
    public GeocodingService(@Value("${api.geocoding.url}") String baseUrl) {
        this(nominatimClient(baseUrl));
    }

    GeocodingService(RestClient nominatim) {
        this.nominatim = nominatim;
    }

    public record Coordinates(double latitude, double longitude) {
    }

    public Optional<Coordinates> locate(String street, String number, String city, String state, String zipCode) {
        String streetLine = number == null || number.isBlank() ? street : number + " " + street;
        try {
            Place[] places = nominatim.get()
                    .uri(uri -> {
                        uri.path("/search")
                                .queryParam("format", "json")
                                .queryParam("limit", 1)
                                .queryParam("countrycodes", "br")
                                .queryParam("street", streetLine)
                                .queryParam("city", city)
                                .queryParam("state", state);
                        if (zipCode != null && !zipCode.isBlank()) {
                            uri.queryParam("postalcode", zipCode);
                        }
                        return uri.build();
                    })
                    .retrieve()
                    .body(Place[].class);

            if (places == null || places.length == 0) {
                return Optional.empty();
            }
            return Optional.of(new Coordinates(Double.parseDouble(places[0].lat()), Double.parseDouble(places[0].lon())));
        } catch (Exception exception) {
            log.warn("Could not geocode \"{}, {} - {}\"", streetLine, city, state, exception);
            return Optional.empty();
        }
    }

    private static RestClient nominatimClient(String baseUrl) {
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(
                HttpClient.newBuilder()
                        .version(HttpClient.Version.HTTP_1_1)
                        .connectTimeout(Duration.ofSeconds(3))
                        .build());
        requestFactory.setReadTimeout(Duration.ofSeconds(8));

        return RestClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader("User-Agent", "AjudaBem/1.0 (TCC)")
                .requestFactory(requestFactory)
                .build();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record Place(String lat, String lon) {
    }
}

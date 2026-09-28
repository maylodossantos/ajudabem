package com.ajudabem.api.services.help_point;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.queryParam;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class GeocodingServiceTest {

    private MockRestServiceServer nominatim;
    private GeocodingService service;

    @BeforeEach
    void setUp() {
        RestClient.Builder builder = RestClient.builder().baseUrl("http://nominatim");
        nominatim = MockRestServiceServer.bindTo(builder).build();
        service = new GeocodingService(builder.build());
    }

    @Test
    void locate_shouldSendAStructuredBrazilianSearchAndReadTheFirstPlace() {
        nominatim.expect(requestTo(startsWith("http://nominatim/search")))
                .andExpect(queryParam("countrycodes", "br"))
                .andExpect(queryParam("street", "1916%20R.%20Rio%20Bor%C3%A1"))
                .andExpect(queryParam("city", "Cascavel"))
                .andExpect(queryParam("postalcode", "85814508"))
                .andRespond(withSuccess("[{\"lat\":\"-24.9207\",\"lon\":\"-53.4388\",\"display_name\":\"x\"}]",
                        MediaType.APPLICATION_JSON));

        var coordinates = service.locate("R. Rio Borá", "1916", "Cascavel", "PR", "85814508");

        assertThat(coordinates).contains(new GeocodingService.Coordinates(-24.9207, -53.4388));
        nominatim.verify();
    }

    @Test
    void locate_shouldGiveUpQuietlyWhenNothingIsFoundOrTheServiceFails() {
        nominatim.expect(requestTo(startsWith("http://nominatim/search")))
                .andRespond(withSuccess("[]", MediaType.APPLICATION_JSON));
        assertThat(service.locate("Rua X", null, "Cascavel", "PR", null)).isEmpty();

        nominatim.reset();
        nominatim.expect(requestTo(startsWith("http://nominatim/search"))).andRespond(withServerError());
        assertThat(service.locate("Rua X", null, "Cascavel", "PR", null)).isEmpty();
    }
}

package com.ajudabem.api.services.help_point;

import com.ajudabem.api.domains.help_point.AssistanceType;
import com.ajudabem.api.domains.help_point.HelpPoint;
import com.ajudabem.api.domains.help_point.HelpPointOrganizationType;
import com.ajudabem.api.domains.help_point.HelpPointSource;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.help_point.HelpPointRequestDTO;
import com.ajudabem.api.dto.help_point.OpeningHoursDTO;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.HelpPointNotFoundException;
import com.ajudabem.api.mappers.HelpPointMapper;
import com.ajudabem.api.repositories.HelpPointRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class HelpPointServiceTest {

    @Mock
    private HelpPointRepository repository;

    @Mock
    private HelpPointMapper mapper;

    @Mock
    private CurrentUserService currentUserService;

    @Mock
    private GeocodingService geocodingService;

    @InjectMocks
    private HelpPointService service;

    private static User user(UserRole role) {
        User user = new User();
        user.setId(1L);
        user.setRole(role);
        return user;
    }

    private static HelpPointRequestDTO request(String street) {
        return new HelpPointRequestDTO(
                "Albergue Municipal Esperança", "Abrigo noturno", null,
                HelpPointOrganizationType.MUNICIPAL_SHELTER,
                Set.of(AssistanceType.SHELTER, AssistanceType.FOOD),
                street, "1916", "Brasmadeira", "Cascavel", "pr", "85814-508",
                "(11) 3942-7810", "(11) 98745-2231", null, "Sra. Marina Costa",
                List.of(new OpeningHoursDTO(DayOfWeek.MONDAY, LocalTime.of(18, 0), LocalTime.of(7, 0))),
                null, "Entrada das 18h às 21h");
    }

    @Test
    void create_shouldNormalizeNumbersKeepHoursAndLocateTheAddress() {
        when(currentUserService.get()).thenReturn(user(UserRole.ADMIN));
        when(geocodingService.locate("R. Rio Borá", "1916", "Cascavel", "PR", "85814508"))
                .thenReturn(Optional.of(new GeocodingService.Coordinates(-24.92, -53.43)));

        service.create(request("R. Rio Borá"));

        verify(repository).save(org.mockito.ArgumentMatchers.argThat(point -> {
            assertThat(point.getSource()).isEqualTo(HelpPointSource.MANUAL);
            assertThat(point.getState()).isEqualTo("PR");
            assertThat(point.getZipCode()).isEqualTo("85814508");
            assertThat(point.getPhone()).isEqualTo("1139427810");
            assertThat(point.getWhatsapp()).isEqualTo("11987452231");
            assertThat(point.getServices()).containsExactlyInAnyOrder(AssistanceType.SHELTER, AssistanceType.FOOD);
            assertThat(point.getOpeningHours()).singleElement()
                    .satisfies(hours -> assertThat(hours.getClosesAt()).isEqualTo(LocalTime.of(7, 0)));
            assertThat(point.getLatitude()).isEqualTo(-24.92);
            return true;
        }));
    }

    @Test
    void create_shouldStillSaveWhenTheAddressCantBeLocated() {
        when(currentUserService.get()).thenReturn(user(UserRole.ADMIN));
        when(geocodingService.locate(any(), any(), any(), any(), any())).thenReturn(Optional.empty());

        service.create(request("Rua Inexistente"));

        verify(repository).save(org.mockito.ArgumentMatchers.argThat(point -> point.getLatitude() == null));
    }

    @Test
    void update_shouldOnlyLocateAgainWhenTheAddressChanged() {
        when(currentUserService.get()).thenReturn(user(UserRole.ADMIN));
        HelpPoint existing = new HelpPoint();
        existing.setStreet("R. Rio Borá");
        existing.setNumber("1916");
        existing.setCity("Cascavel");
        existing.setState("PR");
        existing.setZipCode("85814508");
        existing.setLatitude(-24.92);
        existing.setLongitude(-53.43);
        when(repository.findById(3L)).thenReturn(Optional.of(existing));

        service.update(3L, request("R. Rio Borá"));

        verify(geocodingService, never()).locate(any(), any(), any(), any(), any());
        assertThat(existing.getLatitude()).isEqualTo(-24.92);
    }

    @Test
    void writes_shouldBeAdminOnly() {
        when(currentUserService.get()).thenReturn(user(UserRole.USER_ONG));

        assertThatThrownBy(() -> service.create(request("Rua"))).isInstanceOf(ForbiddenActionException.class);
        assertThatThrownBy(() -> service.update(3L, request("Rua"))).isInstanceOf(ForbiddenActionException.class);
        assertThatThrownBy(() -> service.delete(3L)).isInstanceOf(ForbiddenActionException.class);
        verify(repository, never()).save(any());
        verify(geocodingService, never()).locate(anyString(), any(), any(), any(), any());
    }

    @Test
    void delete_shouldSoftDelete() {
        when(currentUserService.get()).thenReturn(user(UserRole.ADMIN));
        HelpPoint existing = new HelpPoint();
        when(repository.findById(3L)).thenReturn(Optional.of(existing));

        service.delete(3L);

        assertThat(existing.getDeleted()).isTrue();
        verify(repository).save(existing);
    }

    @Test
    void get_shouldThrowNotFound() {
        when(repository.findById(9L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.get(9L)).isInstanceOf(HelpPointNotFoundException.class);
    }
}

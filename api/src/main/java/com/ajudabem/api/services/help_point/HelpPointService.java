package com.ajudabem.api.services.help_point;

import com.ajudabem.api.domains.help_point.HelpPoint;
import com.ajudabem.api.domains.help_point.HelpPointSource;
import com.ajudabem.api.domains.help_point.OpeningHours;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.help_point.HelpPointRequestDTO;
import com.ajudabem.api.dto.help_point.HelpPointResponseDTO;
import com.ajudabem.api.exceptions.HelpPointNotFoundException;
import com.ajudabem.api.infra.validation.Digits;
import com.ajudabem.api.mappers.HelpPointMapper;
import com.ajudabem.api.repositories.HelpPointRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import com.ajudabem.api.services.user.Roles;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class HelpPointService {

    private final HelpPointRepository repository;
    private final HelpPointMapper mapper;
    private final CurrentUserService currentUserService;
    private final GeocodingService geocodingService;

    public List<HelpPointResponseDTO> getAll() {
        return repository.findAllByOrderByCreatedAtDesc().stream()
                .map(mapper::toResponse)
                .toList();
    }

    public HelpPointResponseDTO get(Long id) {
        return mapper.toResponse(findHelpPoint(id));
    }

    @Transactional
    public HelpPointResponseDTO create(HelpPointRequestDTO dto) {
        requireAdmin();

        HelpPoint helpPoint = new HelpPoint();
        helpPoint.setSource(HelpPointSource.MANUAL);
        apply(dto, helpPoint, true);

        repository.save(helpPoint);
        return mapper.toResponse(helpPoint);
    }

    @Transactional
    public HelpPointResponseDTO update(Long id, HelpPointRequestDTO dto) {
        requireAdmin();

        HelpPoint helpPoint = findHelpPoint(id);
        boolean addressChanged = !sameAddress(helpPoint, dto);
        apply(dto, helpPoint, addressChanged);

        repository.save(helpPoint);
        return mapper.toResponse(helpPoint);
    }

    @Transactional
    public void delete(Long id) {
        requireAdmin();

        HelpPoint helpPoint = findHelpPoint(id);
        helpPoint.softDelete();
        repository.save(helpPoint);
    }

    private void apply(HelpPointRequestDTO dto, HelpPoint helpPoint, boolean locate) {
        mapper.updateEntity(dto, helpPoint);
        helpPoint.setState(dto.state().toUpperCase(Locale.ROOT));
        helpPoint.setZipCode(digitsOrNull(dto.zipCode()));
        helpPoint.setPhone(digitsOrNull(dto.phone()));
        helpPoint.setWhatsapp(digitsOrNull(dto.whatsapp()));

        helpPoint.getServices().clear();
        helpPoint.getServices().addAll(dto.services());

        helpPoint.getOpeningHours().clear();
        if (dto.openingHours() != null) {
            dto.openingHours().forEach(hours -> helpPoint.getOpeningHours()
                    .add(new OpeningHours(hours.dayOfWeek(), hours.opensAt(), hours.closesAt())));
        }

        if (locate) {
            var coordinates = geocodingService.locate(
                    dto.street(), dto.number(), dto.city(), helpPoint.getState(), helpPoint.getZipCode());
            helpPoint.setLatitude(coordinates.map(GeocodingService.Coordinates::latitude).orElse(null));
            helpPoint.setLongitude(coordinates.map(GeocodingService.Coordinates::longitude).orElse(null));
        }
    }

    private static boolean sameAddress(HelpPoint helpPoint, HelpPointRequestDTO dto) {
        return Objects.equals(helpPoint.getStreet(), dto.street())
                && Objects.equals(helpPoint.getNumber(), dto.number())
                && Objects.equals(helpPoint.getCity(), dto.city())
                && Objects.equals(helpPoint.getState(), dto.state().toUpperCase(Locale.ROOT))
                && Objects.equals(helpPoint.getZipCode(), digitsOrNull(dto.zipCode()))
                && helpPoint.getLatitude() != null;
    }

    private static String digitsOrNull(String value) {
        if (value == null) {
            return null;
        }
        String digits = Digits.only(value);
        return digits.isEmpty() ? null : digits;
    }

    private void requireAdmin() {
        Roles.requireAdmin(currentUserService.get(), "Only admins can manage help points");
    }

    private HelpPoint findHelpPoint(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new HelpPointNotFoundException("Help point not found"));
    }
}

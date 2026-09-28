package com.ajudabem.api.services.organization;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationDocument;
import com.ajudabem.api.domains.organization.OrganizationDocumentFile;
import com.ajudabem.api.domains.organization.OrganizationDocumentType;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.organization.DocumentFileDTO;
import com.ajudabem.api.dto.organization.OrganizationRequestDTO;
import com.ajudabem.api.dto.organization.OrganizationResponseDTO;
import com.ajudabem.api.dto.organization.RejectOrganizationRequestDTO;
import com.ajudabem.api.exceptions.CnpjAlreadyExistsException;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.InvalidDocumentFileException;
import com.ajudabem.api.exceptions.MissingOrganizationDocumentsException;
import com.ajudabem.api.exceptions.OrganizationAlreadySubmittedException;
import com.ajudabem.api.exceptions.OrganizationDocumentNotFoundException;
import com.ajudabem.api.exceptions.OrganizationNotFoundException;
import com.ajudabem.api.exceptions.OrganizationNotPendingException;
import com.ajudabem.api.exceptions.OrganizationResubmissionTooSoonException;
import com.ajudabem.api.infra.validation.Digits;
import com.ajudabem.api.mappers.OrganizationMapper;
import com.ajudabem.api.repositories.OrganizationDocumentFileRepository;
import com.ajudabem.api.repositories.OrganizationRepository;
import com.ajudabem.api.repositories.UserRepository;
import com.ajudabem.api.services.help_point.GeocodingService;
import com.ajudabem.api.domains.notification.NotificationType;
import com.ajudabem.api.services.notification.NotificationService;
import com.ajudabem.api.services.user.CurrentUserService;
import com.ajudabem.api.services.user.Roles;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class OrganizationService {

    private final OrganizationRepository repository;
    private final OrganizationDocumentFileRepository documentFileRepository;
    private final UserRepository userRepository;
    private final CurrentUserService currentUserService;
    private final OrganizationMapper mapper;
    private final GeocodingService geocodingService;
    private final NotificationService notificationService;

    public OrganizationResponseDTO getMine() {
        return mapper.toResponse(findByOwner(currentUserService.get()));
    }

    @Transactional
    public OrganizationResponseDTO submit(
            OrganizationRequestDTO dto, Map<OrganizationDocumentType, MultipartFile> files) {
        User user = currentUserService.get();
        if (user.getRole() == UserRole.ADMIN) {
            throw new ForbiddenActionException("Admins cannot register an organization");
        }

        Organization organization = repository.findByOwner(user)
                .map(this::requireResubmittable)
                .orElseGet(Organization::new);

        files.values().forEach(OrganizationService::requirePdf);
        boolean everyDocumentSent = Arrays.stream(OrganizationDocumentType.values())
                .allMatch(type -> files.containsKey(type) || organization.getDocuments().stream()
                        .anyMatch(sent -> sent.getType() == type));
        if (!everyDocumentSent) {
            throw new MissingOrganizationDocumentsException("All required documents must be sent");
        }

        String cnpj = Digits.only(dto.cnpj());
        repository.findByCnpj(cnpj)
                .filter(existing -> !existing.getId().equals(organization.getId()))
                .ifPresent(existing -> {
                    throw new CnpjAlreadyExistsException("CNPJ is using");
                });

        LocalDateTime now = LocalDateTime.now();
        mapper.updateEntity(dto, organization);
        organization.setOwner(user);
        organization.setCnpj(cnpj);
        organization.setState(dto.state().toUpperCase(Locale.ROOT));
        organization.setZipCode(Digits.only(dto.zipCode()));
        var coordinates = geocodingService.locate(
                dto.street(), dto.number(), dto.city(), organization.getState(), organization.getZipCode());
        organization.setLatitude(coordinates.map(GeocodingService.Coordinates::latitude).orElse(null));
        organization.setLongitude(coordinates.map(GeocodingService.Coordinates::longitude).orElse(null));
        organization.setStatus(OrganizationStatus.PENDING);
        organization.setSubmittedAt(now);
        organization.setReviewedAt(null);
        organization.setReviewedBy(null);
        organization.setRejectionReason(null);
        organization.setRejectionNote(null);

        repository.save(organization);
        files.forEach((type, file) -> storeDocument(organization, type, file, now));
        return mapper.toResponse(organization);
    }

    public DocumentFileDTO getDocument(Long id, OrganizationDocumentType type) {
        Organization organization = findOrganization(id);
        requireAdminOrOwner(organization, currentUserService.get());

        OrganizationDocument document = organization.getDocuments().stream()
                .filter(sent -> sent.getType() == type)
                .findFirst()
                .orElseThrow(() -> new OrganizationDocumentNotFoundException("Document not found"));
        OrganizationDocumentFile file = documentFileRepository.findByOrganizationIdAndType(id, type)
                .orElseThrow(() -> new OrganizationDocumentNotFoundException("Document not found"));

        return new DocumentFileDTO(document.getFileName(), document.getContentType(), file.getContent());
    }

    public List<OrganizationResponseDTO> list(OrganizationStatus status, String search) {
        requireAdmin(currentUserService.get());

        List<Organization> organizations = status == null
                ? repository.findAllByOrderBySubmittedAtDesc()
                : repository.findAllByStatusOrderBySubmittedAtDesc(status);

        return organizations.stream()
                .filter(organization -> matches(organization, search))
                .map(mapper::toResponse)
                .toList();
    }

    public OrganizationResponseDTO get(Long id) {
        Organization organization = findOrganization(id);
        requireAdminOrOwner(organization, currentUserService.get());

        return mapper.toResponse(organization);
    }

    @Transactional
    public OrganizationResponseDTO approve(Long id) {
        User admin = requireAdmin(currentUserService.get());
        Organization organization = requirePending(findOrganization(id));

        organization.setStatus(OrganizationStatus.APPROVED);
        markReviewed(organization, admin);

        User owner = organization.getOwner();
        owner.setRole(UserRole.USER_ONG);
        userRepository.save(owner);

        repository.save(organization);
        notificationService.notify(owner, NotificationType.ORGANIZATION_APPROVED, "ONG aprovada",
                "A " + organization.getTradeName() + " foi aprovada. Você já pode atender casos e criar iniciativas.",
                organization.getId());
        return mapper.toResponse(organization);
    }

    @Transactional
    public OrganizationResponseDTO reject(Long id, RejectOrganizationRequestDTO dto) {
        User admin = requireAdmin(currentUserService.get());
        Organization organization = requirePending(findOrganization(id));

        organization.setStatus(OrganizationStatus.REJECTED);
        organization.setRejectionReason(dto.reason());
        organization.setRejectionNote(dto.note());
        markReviewed(organization, admin);

        repository.save(organization);
        notificationService.notify(organization.getOwner(), NotificationType.ORGANIZATION_REJECTED,
                "Solicitação reprovada",
                "A solicitação da " + organization.getTradeName() + " foi reprovada. Veja o motivo e reenvie.",
                organization.getId());
        return mapper.toResponse(organization);
    }

    private Organization requireResubmittable(Organization organization) {
        if (organization.getStatus() != OrganizationStatus.REJECTED) {
            throw new OrganizationAlreadySubmittedException("Organization already submitted");
        }
        if (LocalDateTime.now().isBefore(organization.getResubmitAvailableAt())) {
            throw new OrganizationResubmissionTooSoonException(
                    "Organization can only be resubmitted " + Organization.RESUBMISSION_COOLDOWN.toDays()
                            + " days after the rejection");
        }
        return organization;
    }

    private void storeDocument(
            Organization organization, OrganizationDocumentType type, MultipartFile file, LocalDateTime now) {
        documentFileRepository.save(new OrganizationDocumentFile(organization.getId(), type, bytesOf(file)));

        organization.getDocuments().removeIf(sent -> sent.getType() == type);
        organization.getDocuments().add(new OrganizationDocument(
                type, fileNameOf(file, type), "application/pdf", file.getSize(), now));
    }

    private static void requirePdf(MultipartFile file) {
        byte[] content = bytesOf(file);
        String header = new String(content, 0, Math.min(content.length, 5), StandardCharsets.US_ASCII);
        if (content.length > OrganizationDocumentFile.MAX_SIZE_BYTES || !header.equals("%PDF-")) {
            throw new InvalidDocumentFileException("Documents must be PDF files up to 10 MB");
        }
    }

    private static byte[] bytesOf(MultipartFile file) {
        try {
            return file.getBytes();
        } catch (IOException exception) {
            throw new UncheckedIOException(exception);
        }
    }

    private static String fileNameOf(MultipartFile file, OrganizationDocumentType type) {
        String name = StringUtils.getFilename(StringUtils.cleanPath(Objects.toString(file.getOriginalFilename(), "")));
        return StringUtils.hasText(name) ? name : type.name().toLowerCase(Locale.ROOT) + ".pdf";
    }

    private static void requireAdminOrOwner(Organization organization, User user) {
        boolean isOwner = organization.getOwner().getId().equals(user.getId());
        if (!isOwner && user.getRole() != UserRole.ADMIN) {
            throw new ForbiddenActionException("Only admins and the owner can see this organization");
        }
    }

    private static Organization requirePending(Organization organization) {
        if (organization.getStatus() != OrganizationStatus.PENDING) {
            throw new OrganizationNotPendingException("Organization was already reviewed");
        }
        return organization;
    }

    private static User requireAdmin(User user) {
        return Roles.requireAdmin(user, "Only admins can review organizations");
    }

    private static void markReviewed(Organization organization, User admin) {
        organization.setReviewedAt(LocalDateTime.now());
        organization.setReviewedBy(admin);
    }

    private static boolean matches(Organization organization, String search) {
        if (search == null || search.isBlank()) {
            return true;
        }

        String term = search.trim().toLowerCase(Locale.ROOT);
        String digits = Digits.only(term);
        return contains(organization.getTradeName(), term)
                || contains(organization.getCorporateName(), term)
                || (!digits.isEmpty() && organization.getCnpj() != null && organization.getCnpj().contains(digits));
    }

    private static boolean contains(String value, String term) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(term);
    }

    private Organization findByOwner(User owner) {
        return repository.findByOwner(owner)
                .orElseThrow(() -> new OrganizationNotFoundException("Organization not found"));
    }

    private Organization findOrganization(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new OrganizationNotFoundException("Organization not found"));
    }
}

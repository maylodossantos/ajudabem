package com.ajudabem.api.services.organization;

import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationDocument;
import com.ajudabem.api.domains.organization.OrganizationDocumentFile;
import com.ajudabem.api.domains.organization.OrganizationDocumentType;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.organization.RejectionReason;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import com.ajudabem.api.dto.organization.OrganizationRequestDTO;
import com.ajudabem.api.dto.organization.OrganizationResponseDTO;
import com.ajudabem.api.dto.organization.RejectOrganizationRequestDTO;
import com.ajudabem.api.exceptions.CnpjAlreadyExistsException;
import com.ajudabem.api.exceptions.ForbiddenActionException;
import com.ajudabem.api.exceptions.InvalidDocumentFileException;
import com.ajudabem.api.exceptions.MissingOrganizationDocumentsException;
import com.ajudabem.api.exceptions.OrganizationAlreadySubmittedException;
import com.ajudabem.api.exceptions.OrganizationNotPendingException;
import com.ajudabem.api.exceptions.OrganizationResubmissionTooSoonException;
import com.ajudabem.api.mappers.OrganizationMapper;
import com.ajudabem.api.repositories.OrganizationDocumentFileRepository;
import com.ajudabem.api.repositories.OrganizationRepository;
import com.ajudabem.api.repositories.UserRepository;
import com.ajudabem.api.services.user.CurrentUserService;
import com.ajudabem.api.services.help_point.GeocodingService;
import com.ajudabem.api.services.notification.NotificationService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OrganizationServiceTest {

    @Mock
    private OrganizationRepository repository;

    @Mock
    private OrganizationDocumentFileRepository documentFileRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private CurrentUserService currentUserService;

    @Mock
    private OrganizationMapper mapper;

    @Mock
    private GeocodingService geocodingService;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private OrganizationService service;

    private static User user(Long id, UserRole role) {
        User user = new User();
        user.setId(id);
        user.setRole(role);
        return user;
    }

    private static OrganizationRequestDTO request() {
        return new OrganizationRequestDTO(
                "Instituto Esperança LTDA", "Instituto Esperança", "11.222.333/0001-81", "Assistência Social",
                "Rua das Flores", "123", "Centro", "Cascavel", "pr", "85800-000",
                null, "@esperanca", true, true, true);
    }

    private static MultipartFile pdf(String name) {
        return new MockMultipartFile(name, name + ".pdf", "application/pdf",
                "%PDF-1.4 fake".getBytes(StandardCharsets.US_ASCII));
    }

    private static Map<OrganizationDocumentType, MultipartFile> allPdfs() {
        Map<OrganizationDocumentType, MultipartFile> files = new EnumMap<>(OrganizationDocumentType.class);
        Arrays.stream(OrganizationDocumentType.values()).forEach(type -> files.put(type, pdf(type.name())));
        return files;
    }

    private static List<OrganizationDocument> everyDocumentSentBefore() {
        return Arrays.stream(OrganizationDocumentType.values())
                .map(type -> new OrganizationDocument(type, "old.pdf", "application/pdf", 10L,
                        LocalDateTime.now().minusDays(10)))
                .collect(java.util.stream.Collectors.toCollection(java.util.ArrayList::new));
    }

    private static Organization organization(Long id, User owner, OrganizationStatus status) {
        Organization organization = new Organization();
        organization.setId(id);
        organization.setOwner(owner);
        organization.setStatus(status);
        organization.setTradeName("Instituto Esperança");
        organization.setCorporateName("Instituto Esperança LTDA");
        organization.setCnpj("11222333000181");
        return organization;
    }

    @Test
    void submit_shouldCreateAPendingRequestWithNormalizedNumbersAndAllDocuments() {
        User owner = user(1L, UserRole.USER);
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.empty());
        when(repository.findByCnpj("11222333000181")).thenReturn(Optional.empty());

        service.submit(request(), allPdfs());

        verify(repository).save(org(saved -> {
            assertThat(saved.getOwner()).isSameAs(owner);
            assertThat(saved.getStatus()).isEqualTo(OrganizationStatus.PENDING);
            assertThat(saved.getCnpj()).isEqualTo("11222333000181");
            assertThat(saved.getZipCode()).isEqualTo("85800000");
            assertThat(saved.getState()).isEqualTo("PR");
            assertThat(saved.getSubmittedAt()).isNotNull();
        }));
        assertThat(savedDocuments()).hasSize(OrganizationDocumentType.values().length);
    }

    @Test
    void submit_shouldStoreEachPdfAndItsMetadata() {
        User owner = user(1L, UserRole.USER);
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.empty());
        when(repository.findByCnpj("11222333000181")).thenReturn(Optional.empty());

        service.submit(request(), allPdfs());

        verify(documentFileRepository, times(4)).save(any(OrganizationDocumentFile.class));
        assertThat(savedDocuments())
                .extracting(OrganizationDocument::getFileName)
                .containsExactlyInAnyOrder("CNPJ_PROOF.pdf", "BYLAWS.pdf", "BOARD_ELECTION_MINUTES.pdf",
                        "RESPONSIBLE_ID.pdf");
    }

    @Test
    void submit_shouldRefuseFilesThatAreNotPdfs() {
        User owner = user(1L, UserRole.USER);
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.empty());
        Map<OrganizationDocumentType, MultipartFile> files = allPdfs();
        files.put(OrganizationDocumentType.BYLAWS,
                new MockMultipartFile("BYLAWS", "estatuto.pdf", "application/pdf", new byte[]{(byte) 0xFF, (byte) 0xD8}));

        assertThatThrownBy(() -> service.submit(request(), files))
                .isInstanceOf(InvalidDocumentFileException.class);
        verify(repository, never()).save(any());
        verify(documentFileRepository, never()).save(any());
    }

    @Test
    void submit_shouldRequireEveryDocumentOnTheFirstRequest() {
        User owner = user(1L, UserRole.USER);
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.empty());
        Map<OrganizationDocumentType, MultipartFile> files = allPdfs();
        files.remove(OrganizationDocumentType.RESPONSIBLE_ID);

        assertThatThrownBy(() -> service.submit(request(), files))
                .isInstanceOf(MissingOrganizationDocumentsException.class);
        verify(repository, never()).save(any());
    }

    @Test
    void getDocument_shouldOnlyServeThePdfToAdminsAndTheOwner() {
        User owner = user(1L, UserRole.USER);
        Organization organization = organization(5L, owner, OrganizationStatus.PENDING);
        organization.setDocuments(everyDocumentSentBefore());
        when(repository.findById(5L)).thenReturn(Optional.of(organization));
        when(documentFileRepository.findByOrganizationIdAndType(5L, OrganizationDocumentType.BYLAWS))
                .thenReturn(Optional.of(new OrganizationDocumentFile(5L, OrganizationDocumentType.BYLAWS,
                        "%PDF-1.4".getBytes(StandardCharsets.US_ASCII))));

        when(currentUserService.get()).thenReturn(user(2L, UserRole.USER_ONG));
        assertThatThrownBy(() -> service.getDocument(5L, OrganizationDocumentType.BYLAWS))
                .isInstanceOf(ForbiddenActionException.class);

        when(currentUserService.get()).thenReturn(user(9L, UserRole.ADMIN));
        assertThat(service.getDocument(5L, OrganizationDocumentType.BYLAWS).fileName()).isEqualTo("old.pdf");
    }

    private List<OrganizationDocument> savedDocuments() {
        org.mockito.ArgumentCaptor<Organization> captor = org.mockito.ArgumentCaptor.forClass(Organization.class);
        verify(repository).save(captor.capture());
        return captor.getValue().getDocuments();
    }

    @Test
    void submit_shouldForbidAdmins() {
        when(currentUserService.get()).thenReturn(user(1L, UserRole.ADMIN));

        assertThatThrownBy(() -> service.submit(request(), allPdfs())).isInstanceOf(ForbiddenActionException.class);
        verify(repository, never()).save(any());
    }

    @Test
    void submit_shouldRefuseWhileARequestIsPendingOrApproved() {
        User owner = user(1L, UserRole.USER);
        when(currentUserService.get()).thenReturn(owner);

        for (OrganizationStatus status : List.of(OrganizationStatus.PENDING, OrganizationStatus.APPROVED)) {
            when(repository.findByOwner(owner)).thenReturn(Optional.of(organization(5L, owner, status)));

            assertThatThrownBy(() -> service.submit(request(), allPdfs()))
                    .isInstanceOf(OrganizationAlreadySubmittedException.class);
        }
        verify(repository, never()).save(any());
    }

    @Test
    void submit_shouldMakeARejectedOrganizationWaitSevenDays() {
        User owner = user(1L, UserRole.USER);
        Organization rejected = organization(5L, owner, OrganizationStatus.REJECTED);
        rejected.setReviewedAt(LocalDateTime.now().minusDays(6));
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.of(rejected));

        assertThatThrownBy(() -> service.submit(request(), allPdfs()))
                .isInstanceOf(OrganizationResubmissionTooSoonException.class);
        verify(repository, never()).save(any());
    }

    @Test
    void submit_shouldReopenTheSameRequestAfterTheCooldown() {
        User owner = user(1L, UserRole.USER);
        Organization rejected = organization(5L, owner, OrganizationStatus.REJECTED);
        rejected.setReviewedAt(LocalDateTime.now().minusDays(8));
        rejected.setReviewedBy(user(9L, UserRole.ADMIN));
        rejected.setRejectionReason(RejectionReason.ILLEGIBLE_DOCUMENTS);
        rejected.setRejectionNote("Foto borrada");
        rejected.setDocuments(everyDocumentSentBefore());
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.of(rejected));
        when(repository.findByCnpj("11222333000181")).thenReturn(Optional.of(rejected));

        service.submit(request(), Map.of(OrganizationDocumentType.BYLAWS, pdf("estatuto-novo")));

        verify(documentFileRepository, times(1)).save(any(OrganizationDocumentFile.class));
        assertThat(rejected.getDocuments()).hasSize(4)
                .filteredOn(document -> document.getType() == OrganizationDocumentType.BYLAWS)
                .singleElement()
                .extracting(OrganizationDocument::getFileName)
                .isEqualTo("estatuto-novo.pdf");

        assertThat(rejected.getStatus()).isEqualTo(OrganizationStatus.PENDING);
        assertThat(rejected.getReviewedAt()).isNull();
        assertThat(rejected.getReviewedBy()).isNull();
        assertThat(rejected.getRejectionReason()).isNull();
        assertThat(rejected.getRejectionNote()).isNull();
        verify(repository).save(rejected);
    }

    @Test
    void submit_shouldRefuseACnpjAlreadyUsedByAnotherOrganization() {
        User owner = user(1L, UserRole.USER);
        when(currentUserService.get()).thenReturn(owner);
        when(repository.findByOwner(owner)).thenReturn(Optional.empty());
        when(repository.findByCnpj("11222333000181"))
                .thenReturn(Optional.of(organization(7L, user(2L, UserRole.USER_ONG), OrganizationStatus.APPROVED)));

        assertThatThrownBy(() -> service.submit(request(), allPdfs())).isInstanceOf(CnpjAlreadyExistsException.class);
        verify(repository, never()).save(any());
    }

    @Test
    void approve_shouldTurnTheOwnerIntoAnOng() {
        User admin = user(9L, UserRole.ADMIN);
        User owner = user(1L, UserRole.USER);
        Organization pending = organization(5L, owner, OrganizationStatus.PENDING);
        when(currentUserService.get()).thenReturn(admin);
        when(repository.findById(5L)).thenReturn(Optional.of(pending));

        service.approve(5L);

        assertThat(pending.getStatus()).isEqualTo(OrganizationStatus.APPROVED);
        assertThat(pending.getReviewedBy()).isSameAs(admin);
        assertThat(pending.getReviewedAt()).isNotNull();
        assertThat(owner.getRole()).isEqualTo(UserRole.USER_ONG);
        verify(userRepository).save(owner);
        verify(repository).save(pending);
    }

    @Test
    void reject_shouldStoreTheReasonAndStartTheCooldown() {
        User admin = user(9L, UserRole.ADMIN);
        User owner = user(1L, UserRole.USER);
        Organization pending = organization(5L, owner, OrganizationStatus.PENDING);
        when(currentUserService.get()).thenReturn(admin);
        when(repository.findById(5L)).thenReturn(Optional.of(pending));

        service.reject(5L, new RejectOrganizationRequestDTO(RejectionReason.DATA_MISMATCH, "CNPJ diferente do cartão"));

        assertThat(pending.getStatus()).isEqualTo(OrganizationStatus.REJECTED);
        assertThat(pending.getRejectionReason()).isEqualTo(RejectionReason.DATA_MISMATCH);
        assertThat(pending.getRejectionNote()).isEqualTo("CNPJ diferente do cartão");
        assertThat(pending.getResubmitAvailableAt()).isEqualTo(pending.getReviewedAt().plusDays(7));
        assertThat(owner.getRole()).isEqualTo(UserRole.USER);
    }

    @Test
    void review_shouldOnlyHappenOnceAndOnlyByAdmins() {
        User owner = user(1L, UserRole.USER);
        when(repository.findById(5L)).thenReturn(Optional.of(organization(5L, owner, OrganizationStatus.APPROVED)));

        when(currentUserService.get()).thenReturn(user(9L, UserRole.ADMIN));
        assertThatThrownBy(() -> service.approve(5L)).isInstanceOf(OrganizationNotPendingException.class);

        when(currentUserService.get()).thenReturn(user(3L, UserRole.USER_ONG));
        assertThatThrownBy(() -> service.approve(5L)).isInstanceOf(ForbiddenActionException.class);
        assertThatThrownBy(() -> service.reject(5L, new RejectOrganizationRequestDTO(RejectionReason.OTHER, null)))
                .isInstanceOf(ForbiddenActionException.class);
    }

    @Test
    void get_shouldOnlyShowTheRequestToItsOwnerAndAdmins() {
        User owner = user(1L, UserRole.USER);
        Organization organization = organization(5L, owner, OrganizationStatus.PENDING);
        when(repository.findById(5L)).thenReturn(Optional.of(organization));

        when(currentUserService.get()).thenReturn(user(2L, UserRole.USER_ONG));
        assertThatThrownBy(() -> service.get(5L)).isInstanceOf(ForbiddenActionException.class);

        when(currentUserService.get()).thenReturn(owner);
        service.get(5L);
        when(currentUserService.get()).thenReturn(user(9L, UserRole.ADMIN));
        service.get(5L);

        verify(mapper, org.mockito.Mockito.times(2)).toResponse(organization);
    }

    @Test
    void list_shouldFilterByNameOrCnpj() {
        User owner = user(1L, UserRole.USER);
        Organization esperanca = organization(5L, owner, OrganizationStatus.PENDING);
        Organization rios = organization(6L, owner, OrganizationStatus.PENDING);
        rios.setTradeName("Amigos dos Rios");
        rios.setCorporateName("Associação Amigos dos Rios");
        rios.setCnpj("44555666000181");
        when(currentUserService.get()).thenReturn(user(9L, UserRole.ADMIN));
        when(repository.findAllByStatusOrderBySubmittedAtDesc(OrganizationStatus.PENDING))
                .thenReturn(List.of(esperanca, rios));
        OrganizationResponseDTO riosResponse = mock(OrganizationResponseDTO.class);
        when(mapper.toResponse(rios)).thenReturn(riosResponse);

        assertThat(service.list(OrganizationStatus.PENDING, "rios")).containsExactly(riosResponse);
        assertThat(service.list(OrganizationStatus.PENDING, "44.555")).containsExactly(riosResponse);
    }

    private static Organization org(java.util.function.Consumer<Organization> assertions) {
        return org.mockito.ArgumentMatchers.argThat(organization -> {
            assertions.accept(organization);
            return true;
        });
    }
}

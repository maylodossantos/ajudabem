package com.ajudabem.api.domains.organization;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.user.User;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "organizations")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class Organization extends EntityBase {

    public static final Duration RESUBMISSION_COOLDOWN = Duration.ofDays(7);

    @ManyToOne
    @JoinColumn(name = "owner_user_id", nullable = false)
    private User owner;

    private String corporateName;
    private String tradeName;
    private String cnpj;
    private String activityArea;

    private String street;
    private String number;
    private String neighborhood;
    private String city;
    private String state;
    private String zipCode;
    private Double latitude;
    private Double longitude;

    private String website;
    private String instagram;

    @Enumerated(EnumType.STRING)
    private OrganizationStatus status;

    private LocalDateTime submittedAt;
    private LocalDateTime reviewedAt;

    @ManyToOne
    @JoinColumn(name = "reviewed_by_user_id")
    private User reviewedBy;

    @Enumerated(EnumType.STRING)
    private RejectionReason rejectionReason;

    private String rejectionNote;

    @ElementCollection
    @CollectionTable(name = "organization_documents", joinColumns = @JoinColumn(name = "organization_id"))
    private List<OrganizationDocument> documents = new ArrayList<>();

    public LocalDateTime getResubmitAvailableAt() {
        if (status != OrganizationStatus.REJECTED || reviewedAt == null) {
            return null;
        }
        return reviewedAt.plus(RESUBMISSION_COOLDOWN);
    }
}

package com.ajudabem.api.domains.initiative;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.organization.Organization;
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

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "campaigns")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class Campaign extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "organization_id", nullable = false)
    private Organization organization;

    private String title;
    private String donationInfo;
    private String subtitle;
    private String description;

    @Enumerated(EnumType.STRING)
    private CampaignCategory category;

    private BigDecimal goalAmount;
    private LocalDate deadline;
    private String coverImage;

    @Enumerated(EnumType.STRING)
    private InitiativeStatus status = InitiativeStatus.ACTIVE;

    private LocalDateTime finishedAt;
}

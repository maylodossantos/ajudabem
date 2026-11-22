package com.ajudabem.api.domains.initiative;

import com.ajudabem.api.domains.publication.Publication;
import com.ajudabem.api.domains.organization.Organization;
import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@DiscriminatorValue("CAMPAIGN")
@Getter
@Setter
@NoArgsConstructor
public class Campaign extends Publication {

    @ManyToOne
    @JoinColumn(name = "organization_id")
    private Organization organization;

    private String donationInfo;

    @Column(name = "content")
    private String description;

    @Enumerated(EnumType.STRING)
    private CampaignCategory category;

    private BigDecimal goalAmount;
    private LocalDate deadline;
    @Column(name = "cover_image")
    private String coverImage;

    @Enumerated(EnumType.STRING)
    private InitiativeStatus status = InitiativeStatus.ACTIVE;

    private LocalDateTime finishedAt;
}

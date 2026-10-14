package com.ajudabem.api.domains.assisted_person;

import com.ajudabem.api.domains.EntityBase;
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

@Entity
@Table(name = "risk_triage_logs")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class RiskTriageLog extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "assisted_person_id", nullable = false)
    private AssistedPerson assistedPerson;

    @Enumerated(EnumType.STRING)
    private RiskLevel riskLevel;

    private String justification;
    private String model;
    private String input;
    private Long durationMs;
}

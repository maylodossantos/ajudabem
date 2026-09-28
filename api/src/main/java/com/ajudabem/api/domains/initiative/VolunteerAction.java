package com.ajudabem.api.domains.initiative;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.organization.Organization;
import jakarta.persistence.Column;
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

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "volunteer_actions")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class VolunteerAction extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "organization_id", nullable = false)
    private Organization organization;

    private String title;

    @Column(name = "action_date")
    private LocalDate date;

    private LocalTime startTime;
    private LocalTime endTime;
    private Integer volunteersNeeded;

    private String street;
    private String number;
    private String city;
    private String state;
    private String zipCode;

    private String description;
    private String tasks;
    private String requirements;
    private String notes;

    @Enumerated(EnumType.STRING)
    private InitiativeStatus status = InitiativeStatus.ACTIVE;

    private LocalDateTime finishedAt;
}

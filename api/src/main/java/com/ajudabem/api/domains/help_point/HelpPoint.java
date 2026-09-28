package com.ajudabem.api.domains.help_point;

import com.ajudabem.api.domains.EntityBase;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "help_points")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class HelpPoint extends EntityBase {

    private String name;
    private String description;
    private String coverImage;

    @Enumerated(EnumType.STRING)
    private HelpPointOrganizationType organizationType;

    @ElementCollection
    @CollectionTable(name = "help_point_services", joinColumns = @JoinColumn(name = "help_point_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "service")
    private Set<AssistanceType> services = new HashSet<>();

    private String street;
    private String number;
    private String neighborhood;
    private String city;
    private String state;
    private String zipCode;

    private Double latitude;
    private Double longitude;

    private String phone;
    private String whatsapp;
    private String email;
    private String responsible;

    @ElementCollection
    @CollectionTable(name = "help_point_opening_hours", joinColumns = @JoinColumn(name = "help_point_id"))
    private List<OpeningHours> openingHours = new ArrayList<>();

    private String scheduleNote;

    private String notes;

    @Enumerated(EnumType.STRING)
    private HelpPointSource source;

    private String externalId;
}

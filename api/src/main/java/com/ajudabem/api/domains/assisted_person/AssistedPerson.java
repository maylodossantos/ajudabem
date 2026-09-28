package com.ajudabem.api.domains.assisted_person;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.care.CareStatus;
import com.ajudabem.api.domains.care.FinishReason;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.user.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "assisted_people")
@SQLRestriction("deleted = false")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class AssistedPerson extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "created_user_id", nullable = false)
    private User author;

    private String full_name;
    private Integer age;
    private Gender gender;

    private RiskLevel riskLevel;

    private String notes;

    private String street;
    private String number;
    private String neighborhood;
    private String city;
    private String state;
    private String zip_code;
    private String country;

    private Double latitude;
    private Double longitude;

    @Enumerated(EnumType.STRING)
    private CareStatus careStatus = CareStatus.NOMINATED;

    @ManyToOne
    @JoinColumn(name = "organization_id")
    private Organization organization;

    private LocalDateTime careStartedAt;
    private LocalDateTime careUpdatedAt;

    @Enumerated(EnumType.STRING)
    private FinishReason finishReason;

    @ManyToMany
    @JoinTable(
            name = "assisted_person_tags",
            joinColumns = @JoinColumn(name = "assisted_person_id"),
            inverseJoinColumns = @JoinColumn(name = "tag_id")
    )
    private List<Tag> tags;
}

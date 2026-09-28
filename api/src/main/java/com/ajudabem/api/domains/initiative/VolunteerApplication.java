package com.ajudabem.api.domains.initiative;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.user.User;
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
@Table(name = "volunteer_applications")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class VolunteerApplication extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "action_id", nullable = false)
    private VolunteerAction action;

    @ManyToOne
    @JoinColumn(name = "volunteer_user_id", nullable = false)
    private User volunteer;

    @Enumerated(EnumType.STRING)
    private ApplicationStatus status = ApplicationStatus.PENDING;
}

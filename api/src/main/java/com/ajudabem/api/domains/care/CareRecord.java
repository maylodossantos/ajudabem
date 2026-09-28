package com.ajudabem.api.domains.care;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.assisted_person.AssistedPerson;
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

import java.time.LocalDateTime;

@Entity
@Table(name = "care_records")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class CareRecord extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "assisted_person_id", nullable = false)
    private AssistedPerson assistedPerson;

    @ManyToOne
    @JoinColumn(name = "author_user_id", nullable = false)
    private User author;

    private Integer number;

    @Enumerated(EnumType.STRING)
    private CareRecordStatus status;

    private LocalDateTime occurredAt;
    private String situation;
    private String actionTaken;
    private String referral;
    private String nextStep;
    private String summary;
    private String note;

    @Enumerated(EnumType.STRING)
    private FinishReason finishReason;
}

package com.ajudabem.api.domains.publication;

import com.ajudabem.api.domains.EntityBase;
import jakarta.persistence.DiscriminatorColumn;
import jakarta.persistence.DiscriminatorType;
import jakarta.persistence.Entity;
import jakarta.persistence.Inheritance;
import jakarta.persistence.InheritanceType;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "publications")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "kind", discriminatorType = DiscriminatorType.STRING, length = 20)
@SQLRestriction("deleted = false")
@Getter
@Setter
public abstract class Publication extends EntityBase {

    private String title;
    private String subtitle;
}

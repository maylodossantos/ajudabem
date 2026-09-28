package com.ajudabem.api.domains.assisted_person;

import com.ajudabem.api.domains.EntityBase;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "tags")
@SQLRestriction("deleted = false")
@Getter
@Setter
@NoArgsConstructor
public class Tag extends EntityBase {

    private String name;
}

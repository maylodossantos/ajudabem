package com.ajudabem.api.domains.assisted_person;

import com.ajudabem.api.domains.EntityBase;
import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Table(name = "assisted_person_tags")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class AssistedPersonTag extends EntityBase {

    @ManyToOne
    private AssistedPerson assistedPerson;

    @ManyToOne
    private Tag tag;
}
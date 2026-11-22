package com.ajudabem.api.domains.news;

import com.ajudabem.api.domains.publication.Publication;
import com.ajudabem.api.domains.user.User;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@DiscriminatorValue("NEWS")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class News extends Publication {

    @ManyToOne
    @JoinColumn(name = "author_user_id")
    private User author;

    private String content;
    private String cover_image;
    private String city;
    private String state;

    @Enumerated(EnumType.STRING)
    private NewsCategory category;

}

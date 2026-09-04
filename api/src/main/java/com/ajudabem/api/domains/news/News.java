package com.ajudabem.api.domains.news;

import com.ajudabem.api.domains.EntityBase;
import com.ajudabem.api.domains.user.User;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "news")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class News extends EntityBase {

    @ManyToOne
    @JoinColumn(name = "author_user_id", nullable = false)
    private User author;

    private String title;
    private String subtitle;
    private String content;
    private String cover_image;

}

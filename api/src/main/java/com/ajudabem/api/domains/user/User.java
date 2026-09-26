package com.ajudabem.api.domains.user;

import com.ajudabem.api.domains.EntityBase;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.SQLRestriction;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@SQLRestriction("deleted = false")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class User extends EntityBase {

    private String name;
    private String email;
    private String password;
    private String phone;
    private String profile_image;
    private String cpf;
    private UserRole role;
    private LocalDate birth_date;
    private LocalDateTime last_login_at;
    private LocalDateTime termsAcceptedAt;

    private String resetPasswordCode;
    private LocalDateTime resetPasswordCodeExpiresAt;
    private String resetPasswordToken;
    private LocalDateTime resetPasswordTokenExpiresAt;
}

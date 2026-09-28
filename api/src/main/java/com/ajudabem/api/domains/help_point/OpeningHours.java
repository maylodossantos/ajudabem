package com.ajudabem.api.domains.help_point;

import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.DayOfWeek;
import java.time.LocalTime;

@Embeddable
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OpeningHours {

    @Enumerated(EnumType.STRING)
    private DayOfWeek dayOfWeek;

    private LocalTime opensAt;

    private LocalTime closesAt;
}

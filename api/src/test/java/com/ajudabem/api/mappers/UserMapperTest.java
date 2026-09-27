package com.ajudabem.api.mappers;

import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.dto.user.UpdateUserRequestDTO;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;

class UserMapperTest {

    private final UserMapper mapper = new UserMapperImpl();

    @Test
    void updateEntity_shouldMapProfileImageOntoTheSnakeCaseEntityField() {
        User user = new User();
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO(null, null, "https://i.ibb.co/abc123/photo.png", null, null);

        mapper.updateEntity(dto, user);

        assertThat(user.getProfile_image()).isEqualTo("https://i.ibb.co/abc123/photo.png");
    }

    @Test
    void updateEntity_shouldLeaveProfileImageUntouchedWhenNotProvided() {
        User user = new User();
        user.setProfile_image("https://i.ibb.co/existing/photo.png");
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO("New Name", null, null, null, null);

        mapper.updateEntity(dto, user);

        assertThat(user.getProfile_image()).isEqualTo("https://i.ibb.co/existing/photo.png");
        assertThat(user.getName()).isEqualTo("New Name");
    }

    @Test
    void updateEntity_shouldMapBirthDateButLeaveTheCpfToTheService() {
        User user = new User();
        user.setCpf("52998224725");
        UpdateUserRequestDTO dto = new UpdateUserRequestDTO(null, null, null, "111.444.777-35", LocalDate.of(2000, 5, 10));

        mapper.updateEntity(dto, user);

        assertThat(user.getBirth_date()).isEqualTo(LocalDate.of(2000, 5, 10));
        assertThat(user.getCpf()).isEqualTo("52998224725");
    }
}

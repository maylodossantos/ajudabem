package com.ajudabem.api.infra.validation;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;

class CpfValidatorTest {

    private final CpfValidator validator = new CpfValidator();

    @ParameterizedTest
    @ValueSource(strings = {"529.982.247-25", "52998224725", "111.444.777-35"})
    void shouldAcceptCpfsWithValidCheckDigits(String cpf) {
        assertThat(validator.isValid(cpf, null)).isTrue();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "529.982.247-26",   // wrong last check digit
            "529.982.247-15",   // wrong first check digit
            "111.111.111-11",   // repeated digits pass the math but are not real CPFs
            "5299822472",       // too short
            "529982247250",     // too long
            "529-982-247.25",   // mangled mask
            "abc.def.ghi-jk",
            ""
    })
    void shouldRejectInvalidCpfs(String cpf) {
        assertThat(validator.isValid(cpf, null)).isFalse();
    }

    @Test
    void shouldLetNullThrough_soPartialUpdatesCanOmitIt() {
        assertThat(validator.isValid(null, null)).isTrue();
    }

    @Test
    void digitsOnly_shouldStripTheMask() {
        assertThat(CpfValidator.digitsOnly("529.982.247-25")).isEqualTo("52998224725");
    }
}

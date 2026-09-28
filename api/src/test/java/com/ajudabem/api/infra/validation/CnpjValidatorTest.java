package com.ajudabem.api.infra.validation;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;

class CnpjValidatorTest {

    private final CnpjValidator validator = new CnpjValidator();

    @ParameterizedTest
    @ValueSource(strings = {"11.222.333/0001-81", "11222333000181", "12.345.678/0001-95"})
    void shouldAcceptCnpjsWithValidCheckDigits(String cnpj) {
        assertThat(validator.isValid(cnpj, null)).isTrue();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "11.222.333/0001-82",
            "11.222.333/0001-71",
            "12.345.678/0001-90",
            "11.111.111/1111-11",
            "1122233300018",
            "112223330001811",
            "11-222-333.0001/81",
            ""
    })
    void shouldRejectInvalidCnpjs(String cnpj) {
        assertThat(validator.isValid(cnpj, null)).isFalse();
    }

    @Test
    void shouldLetNullThrough() {
        assertThat(validator.isValid(null, null)).isTrue();
    }

    @Test
    void digitsOnly_shouldStripTheMask() {
        assertThat(Digits.only("11.222.333/0001-81")).isEqualTo("11222333000181");
    }
}

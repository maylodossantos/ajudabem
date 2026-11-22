package com.ajudabem.api.services.assisted_person;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class TriageJustificationTest {

    @Test
    void dropsTheSentenceThatOnlyRestatesTheLevel() {
        String raw = "O indivíduo é encontrado sem cobertor em um local de alto risco climático, "
                + "o que indica uma necessidade imediata de abrigo e proteção contra a temperatura "
                + "extremamente baixa. Este fator justifica a classificação como HIGH.";

        assertThat(TriageJustification.clean(raw)).isEqualTo(
                "O indivíduo é encontrado sem cobertor em um local de alto risco climático, "
                        + "o que indica uma necessidade imediata de abrigo e proteção contra a temperatura "
                        + "extremamente baixa.");
    }

    @Test
    void keepsFactsThatMerelyUseWordsLikeAltoOrBaixa() {
        String raw = "Pessoa idosa sozinha, com febre alta e pouca comida.";

        assertThat(TriageJustification.clean(raw)).isEqualTo(raw);
    }

    @Test
    void keepsTheTextWhenEverySentenceMentionsTheLevel() {
        String raw = "Classificado como HIGH.";

        assertThat(TriageJustification.clean(raw)).isEqualTo(raw);
    }

    @Test
    void leavesEmptyJustificationsAlone() {
        assertThat(TriageJustification.clean(null)).isNull();
        assertThat(TriageJustification.clean("")).isEmpty();
    }
}

package com.ajudabem.api.domains.care;

import java.util.Set;

public enum CareRecordStatus {
    IN_CARE,
    REFERRED,
    UNSUCCESSFUL_ATTEMPT,
    AWAITING_RETURN,
    PROGRESS_UPDATE,
    FINISHED;

    public static final Set<CareRecordStatus> FIRST_ACTIONS =
            Set.of(IN_CARE, REFERRED, UNSUCCESSFUL_ATTEMPT, FINISHED);

    public static final Set<CareRecordStatus> FOLLOW_UP_ACTIONS =
            Set.of(AWAITING_RETURN, PROGRESS_UPDATE, UNSUCCESSFUL_ATTEMPT, FINISHED);

    public boolean allowedAt(int recordNumber) {
        return (recordNumber == 1 ? FIRST_ACTIONS : FOLLOW_UP_ACTIONS).contains(this);
    }
}

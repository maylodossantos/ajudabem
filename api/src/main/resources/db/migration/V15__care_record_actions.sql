UPDATE care_records SET status = 'IN_CARE' WHERE status = 'STARTED';
UPDATE care_records SET status = 'PROGRESS_UPDATE' WHERE status = 'IN_PROGRESS';

UPDATE care_records SET finish_reason = 'COULD_NOT_HELP'
WHERE finish_reason IN ('AWAITING_RETURN', 'UNSUCCESSFUL_ATTEMPT');
UPDATE assisted_people SET finish_reason = 'COULD_NOT_HELP'
WHERE finish_reason IN ('AWAITING_RETURN', 'UNSUCCESSFUL_ATTEMPT');

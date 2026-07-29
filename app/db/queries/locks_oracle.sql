-- Sessões bloqueadas e quem está bloqueando, com tempo de espera.
-- Ajustar/enriquecer conforme necessidade (ex: incluir SQL_TEXT via v$sql).
SELECT
    blocking.sid          AS blocking_sid,
    blocking.serial#      AS blocking_serial,
    blocking.username     AS blocking_user,
    blocking.osuser       AS blocking_osuser,
    blocking.machine      AS blocking_machine,
    waiting.sid           AS waiting_sid,
    waiting.serial#       AS waiting_serial,
    waiting.username      AS waiting_user,
    waiting.machine       AS waiting_machine,
    waiting.seconds_in_wait,
    waiting.event         AS wait_event
FROM v$session waiting
JOIN v$session blocking
    ON waiting.blocking_session = blocking.sid
WHERE waiting.blocking_session IS NOT NULL
ORDER BY waiting.seconds_in_wait DESC

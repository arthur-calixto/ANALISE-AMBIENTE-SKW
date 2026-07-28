-- Sessões bloqueadas e quem está bloqueando, com tempo de espera.
SELECT
    r.session_id          AS waiting_session_id,
    r.blocking_session_id AS blocking_session_id,
    r.wait_type,
    r.wait_time            AS wait_time_ms,
    r.status,
    s_wait.login_name      AS waiting_login,
    s_block.login_name     AS blocking_login,
    r.command,
    t.text                 AS waiting_sql_text
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s_wait  ON r.session_id = s_wait.session_id
LEFT JOIN sys.dm_exec_sessions s_block ON r.blocking_session_id = s_block.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC

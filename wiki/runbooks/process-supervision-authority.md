# Process Supervision Authority

## Principle

Every deployed process has exactly one authoritative lifecycle owner.
Health checks must use that owner.
Legacy artifacts may be useful, but they are advisory unless explicitly declared authoritative.

## Why This Exists

On 2026-05-17 Hermes cron failed because health checks trusted Hermes PID semantics after
Hermes had been moved under Zo User Service supervision.
The process owner changed. The health model did not.
That mismatch caused:
- false gateway health assumptions
- missed scheduler dispatch
- stale or missing PID confusion
- manual recovery requirement

## Authority Map

| Deployment Model | Authoritative Health Source | Advisory Signals |
|---|---|---|
| nohup | process table + shell-started PID | logs |
| bashrc autostart | login shell behavior + process table | PID files |
| systemd | `systemctl status SERVICE` | process table, PID files |
| supervisord | `supervisorctl status SERVICE` | process table, PID files |
| Zo User Service | `supervisorctl -c /etc/zo/supervisord-user.conf status` | process table, PID files |
| Hermes gateway internal | Hermes CLI health + gateway PID | external supervisor state |

## Rules

1. Never infer health from legacy artifacts after a migration.
2. PID files are advisory unless the deployment model explicitly makes them authoritative.
3. Scheduler health, process health, and delivery health are separate.
4. Cron job listed does not prove cron dispatch.
5. Supervised process running does not prove the scheduler is dispatching.
6. Delivery is not real until externally verified.
7. For Telegram delivery, message ID must be logged.
8. For critical jobs, watchdogs must run outside the system they watch.
9. If a process changes owner, update:
   - health check
   - runbook
   - incident log
   - manifest
   - watchdog assumptions
10. If the same failure class appears twice, move enforcement down from prose into code.

## Hermes Under Zo User Service

Authoritative command:

```bash
supervisorctl -c /etc/zo/supervisord-user.conf status hermes-gateway
```

For health checks, always use `supervisorctl` under Zo User Service.
Do not trust `gateway.pid` for health under this model.

## Related

- `wiki/incidents/2026-05-17-hermes-gateway-supervision-failure.md`
- `wiki/runbooks/hermes-gateway-service.md`

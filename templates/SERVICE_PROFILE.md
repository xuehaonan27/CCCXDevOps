# Service Profile

## Service

- **Name:** <!-- e.g., user-api -->
- **Repository:** <!-- e.g., github.com/org/repo -->
- **Language / Framework:** <!-- e.g., Node.js / Express -->

## Environments

| Environment | URL / Host | Notes |
|---|---|---|
| Development | <!-- e.g., localhost:3000 --> | |
| Staging | <!-- e.g., staging.example.com --> | |
| Production | <!-- e.g., api.example.com --> | |

## Health Endpoints

| Endpoint | Method | Expected Status | Expected Body (substring) |
|---|---|---|---|
| <!-- e.g., /health --> | GET | 200 | <!-- e.g., "ok" --> |
| <!-- e.g., /readiness --> | GET | 200 | |

## Deploy

- **Deploy command:** <!-- e.g., ./scripts/deploy.sh staging -->
- **Deploy mechanism:** <!-- e.g., Docker push + Kubernetes rollout, rsync, Vercel CLI -->
- **Typical deploy time:** <!-- e.g., ~3 minutes -->

## Rollback

- **Rollback command:** <!-- e.g., kubectl rollout undo deployment/user-api -->
- **Rollback steps (if no single command):**
  1. <!-- Step 1 -->
  2. <!-- Step 2 -->
- **Rollback verification:** <!-- how to confirm rollback succeeded -->

## Validation Commands

<!-- Commands to run after deployment to verify success beyond health checks -->

```bash
# Example: check deployed version
# curl -s https://api.example.com/version | jq .version

# Example: verify critical functionality
# curl -s https://api.example.com/smoke-test
```

## Monitoring

- **Dashboard:** <!-- URL to monitoring dashboard -->
- **Logs:** <!-- how to access logs, e.g., kubectl logs, CloudWatch -->
- **Alerts:** <!-- what alerts exist, where they fire -->

## Critical Notes

<!-- Anything an operator must know: maintenance windows, dependent services, known issues -->

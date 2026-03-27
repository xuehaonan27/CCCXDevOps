# Deploy Safety Checklist

Used by `cccx-deploy` and the `deploy-safety` review profile.

## Pre-Deployment

- [ ] **Target environment confirmed** -- explicitly stated, not assumed
- [ ] **Rollback documented** -- command or step-by-step, tested at least once
- [ ] **Blast radius understood** -- which users/services are affected
- [ ] **Tests pass** -- full test suite on the exact commit being deployed
- [ ] **Code reviewed** -- approved by reviewer (human or Codex)
- [ ] **SERVICE_PROFILE.md exists** -- service name, endpoints, deploy command, rollback command
- [ ] **Validation commands defined** -- commands that verify deployment beyond health checks
- [ ] **Post-deploy monitor window defined** -- duration, what to watch, who to escalate to

## During Deployment

- [ ] **Monitoring dashboard open** -- watching error rates, latency, resource usage
- [ ] **Deploy command matches SERVICE_PROFILE** -- no improvised commands
- [ ] **Each step verified before proceeding** -- don't batch deploy steps blindly

## Post-Deployment

- [ ] **Health endpoints return expected status**
- [ ] **Validation commands pass**
- [ ] **No error spike in monitoring** -- compare to pre-deploy baseline
- [ ] **Monitor window completed** -- stayed within threshold for full duration

## Rollback Triggers

Initiate rollback if ANY of these occur:

- Health endpoint returns non-200 status
- Error rate exceeds pre-deploy baseline by >50%
- Validation commands fail
- User-facing functionality is broken
- Resource usage (CPU, memory) spikes unexpectedly

## Rollback Verification

After rollback:

- [ ] Health endpoints return expected status
- [ ] Validation commands pass
- [ ] Error rate returns to pre-deploy baseline
- [ ] Service is stable for at least 5 minutes

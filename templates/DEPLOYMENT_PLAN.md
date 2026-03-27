# Deployment Plan

## Overview

- **Service:** <!-- from SERVICE_PROFILE.md -->
- **Target environment:** <!-- staging / production -->
- **What is being deployed:** <!-- version, PR, commit SHA -->
- **Deployer:** <!-- who is performing the deployment -->
- **Date:** <!-- YYYY-MM-DD -->

## Pre-Deployment Checklist

- [ ] All tests pass on the branch/commit being deployed
- [ ] Code has been reviewed and approved
- [ ] SERVICE_PROFILE.md is up to date
- [ ] Rollback steps are documented and verified
- [ ] Monitoring dashboard is open and accessible
- [ ] Stakeholders notified (if required)

## Changes Being Deployed

<!-- Brief summary of what changed. Link to PR or commit log. -->

## Deployment Steps

1. <!-- Step 1: e.g., build container image -->
2. <!-- Step 2: e.g., push to registry -->
3. <!-- Step 3: e.g., apply deployment -->
4. <!-- Step 4: e.g., verify rollout -->

## Post-Deployment Validation

<!-- Commands from SERVICE_PROFILE.md validation_commands section -->

```bash
# Health check
# Validation command 1
# Validation command 2
```

- [ ] Health endpoints return expected status
- [ ] Validation commands pass
- [ ] No error spike in monitoring

## Rollback Plan

- **Trigger:** <!-- when to rollback: error rate > X%, health check fails, etc. -->
- **Command:** <!-- from SERVICE_PROFILE.md -->
- **Verification:** <!-- how to confirm rollback succeeded -->

## Monitor Window

- **Duration:** <!-- e.g., 15 minutes post-deploy -->
- **What to watch:** <!-- error rates, latency, resource usage -->
- **Escalation:** <!-- who to contact if issues arise -->

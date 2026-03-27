# Review Profile: deploy-safety

## Intent

Evaluate a deployment plan for safety, rollback coverage, and blast radius before execution.

## Required Evidence

- SERVICE_PROFILE.md (service name, environments, health endpoints, deploy/rollback commands, validation commands)
- Deployment plan (target environment, changes, steps, validation, rollback trigger)
- Test results for the commit being deployed
- Current service health status (if available)

## Review Questions

1. **Rollback plan:** Is the rollback command/process documented and verified?
2. **Blast radius:** Which users/services are affected? Is the scope contained?
3. **Validation:** Are post-deployment validation commands defined and specific?
4. **Monitor window:** Is there a defined monitoring period with clear escalation?
5. **Pre-flight:** Do all pre-deployment checks pass (tests, review, environment)?
6. **Gradual rollout:** For production deploys, is there a staged/canary approach, or is it all-at-once with justification?
7. **Secrets:** Are there new secrets/config changes? Are they handled safely?
8. **Dependencies:** Does the deploy depend on other services being updated first?

## Approval Threshold

- APPROVE: Deployment plan is safe, rollback is documented, validation is defined, blast radius is understood
- REQUEST_CHANGES: Missing rollback steps, undefined validation, or unclear blast radius
- BLOCK: No rollback plan, deploying untested code, or production deploy without explicit confirmation

## Special Rules

- BLOCK automatically if SERVICE_PROFILE.md is missing
- BLOCK automatically if rollback command/steps are empty
- BLOCK automatically if target environment is production and no explicit user confirmation is documented

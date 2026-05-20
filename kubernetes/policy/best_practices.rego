# policy/best_practices.rego
# Warnings for best practices NOT covered by your Gatekeeper ConstraintTemplates.
# These use 'warn' not 'deny' — they show in the report but don't block the build.
# Promote any of these to 'deny' when you're ready to enforce them strictly.

package main

# ── Liveness probe missing (warn only) ───────────────────────────────────────
warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf(
        "[best_practices] Container '%v' in Deployment '%v' should define a livenessProbe",
        [container.name, input.metadata.name]
    )
}

# ── Readiness probe missing (warn only) ──────────────────────────────────────
warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    msg := sprintf(
        "[best_practices] Container '%v' in Deployment '%v' should define a readinessProbe",
        [container.name, input.metadata.name]
    )
}

# ── runAsNonRoot not set (warn only) ─────────────────────────────────────────
warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.securityContext.runAsNonRoot
    msg := sprintf(
        "[best_practices] Container '%v' in Deployment '%v' should set securityContext.runAsNonRoot=true",
        [container.name, input.metadata.name]
    )
}

# ── readOnlyRootFilesystem not set (warn only) ────────────────────────────────
warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem
    msg := sprintf(
        "[best_practices] Container '%v' in Deployment '%v' should set securityContext.readOnlyRootFilesystem=true",
        [container.name, input.metadata.name]
    )
}

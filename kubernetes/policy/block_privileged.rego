# policy/block_privileged.rego
# Extracted from:
#   kubernetes/base/gatekeeper/constrainttemplate2.yaml  (k8sblockprivileged)
#   kubernetes/base/gatekeeper/constrainttemplate3.yaml  (k8sblockprivileged)
#
# Gatekeeper enforces this at cluster admission.
# Conftest enforces this in CI before manifests reach the cluster.

package main

# ── Block privileged containers ───────────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf(
        "[block_privileged] Privileged container is not allowed: '%v' in Deployment '%v'",
        [container.name, input.metadata.name]
    )
}

# ── Block privileged init containers ─────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.initContainers[_]
    container.securityContext.privileged == true
    msg := sprintf(
        "[block_privileged] Privileged init container is not allowed: '%v' in Deployment '%v'",
        [container.name, input.metadata.name]
    )
}

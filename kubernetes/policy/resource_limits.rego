# policy/resource_limits.rego
# Extracted from:
#   kubernetes/base/gatekeeper/constraint-template.yaml  (k8srequiredresourcelimits)
#   kubernetes/base/gatekeeper/constrainttemplate3.yaml  (k8srequireresourcelimits)
#
# Gatekeeper enforces this at cluster admission.
# Conftest enforces this in CI before manifests reach the cluster.

package main

# ── Containers must set CPU limit ────────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
    msg := sprintf(
        "[resource_limits] Container '%v' in Deployment '%v' must set resources.limits.cpu",
        [container.name, input.metadata.name]
    )
}

# ── Containers must set memory limit ─────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf(
        "[resource_limits] Container '%v' in Deployment '%v' must set resources.limits.memory",
        [container.name, input.metadata.name]
    )
}

# ── InitContainers must set CPU limit ────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.initContainers[_]
    not container.resources.limits.cpu
    msg := sprintf(
        "[resource_limits] InitContainer '%v' in Deployment '%v' must set resources.limits.cpu",
        [container.name, input.metadata.name]
    )
}

# ── InitContainers must set memory limit ─────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.initContainers[_]
    not container.resources.limits.memory
    msg := sprintf(
        "[resource_limits] InitContainer '%v' in Deployment '%v' must set resources.limits.memory",
        [container.name, input.metadata.name]
    )
}

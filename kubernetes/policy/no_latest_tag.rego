# policy/no_latest_tag.rego
# Extracted from:
#   kubernetes/base/gatekeeper/constrainttemplate2.yaml  (k8snolatesttag)
#
# Gatekeeper enforces this at cluster admission.
# Conftest enforces this in CI before manifests reach the cluster.

package main

# ── Block :latest tag ─────────────────────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "[no_latest_tag] Container '%v' in Deployment '%v' must not use ':latest' tag. Pin a specific version.",
        [container.name, input.metadata.name]
    )
}

# ── Block missing tag entirely ────────────────────────────────────────────────
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf(
        "[no_latest_tag] Container '%v' in Deployment '%v' has no image tag. Specify a version tag.",
        [container.name, input.metadata.name]
    )
}

package main

# WARN: missing liveness probe
warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.livenessProbe
    msg := sprintf(
        "[probes] Deployment '%s': container '%s' should define a livenessProbe",
        [input.metadata.name, container.name]
    )
}

# WARN: missing readiness probe
warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.readinessProbe
    msg := sprintf(
        "[probes] Deployment '%s': container '%s' should define a readinessProbe",
        [input.metadata.name, container.name]
    )
}
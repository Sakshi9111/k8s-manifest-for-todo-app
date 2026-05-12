package main

# DENY: missing memory limit
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf(
        "[resources] Deployment '%s': container '%s' must set resources.limits.memory",
        [input.metadata.name, container.name]
    )
}

# DENY: missing CPU limit
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
    msg := sprintf(
        "[resources] Deployment '%s': container '%s' must set resources.limits.cpu",
        [input.metadata.name, container.name]
    )
}

# DENY: missing memory request
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.memory
    msg := sprintf(
        "[resources] Deployment '%s': container '%s' must set resources.requests.memory",
        [input.metadata.name, container.name]
    )
}

# DENY: missing CPU request
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
    msg := sprintf(
        "[resources] Deployment '%s': container '%s' must set resources.requests.cpu",
        [input.metadata.name, container.name]
    )
}
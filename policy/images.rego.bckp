package main

# DENY: container image uses :latest tag
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf(
        "[images] Deployment '%s': container '%s' uses ':latest' tag — pin to a specific version or digest",
        [input.metadata.name, container.name]
    )
}

# DENY: container image has no tag at all
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf(
        "[images] Deployment '%s': container '%s' has no tag — pin to a specific version",
        [input.metadata.name, container.name]
    )
}

# DENY: image is not from approved registry (Docker Hub user '98543218')
deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not startswith(container.image, "98543218/")
    not startswith(container.image, "docker.io/98543218/")
    msg := sprintf(
        "[images] Deployment '%s': container '%s' image '%s' is not from approved registry '98543218/'",
        [input.metadata.name, container.name, container.image]
    )
}
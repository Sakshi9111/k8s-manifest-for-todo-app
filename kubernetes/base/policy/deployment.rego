package main

import future.keywords.in

deny[msg] {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[_].resources.limits.memory
    msg := sprintf("Deployment '%s': container must set resources.limits.memory", [input.metadata.name])
}

deny[msg] {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[_].resources.limits.cpu
    msg := sprintf("Deployment '%s': container must set resources.limits.cpu", [input.metadata.name])
}

deny[msg] {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[_].resources.requests.memory
    msg := sprintf("Deployment '%s': container must set resources.requests.memory", [input.metadata.name])
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    endswith(container.image, ":latest")
    msg := sprintf("Deployment '%s': container '%s' uses ':latest' tag — pin to a digest or version", [input.metadata.name, container.name])
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not contains(container.image, ":")
    msg := sprintf("Deployment '%s': container '%s' has no tag", [input.metadata.name, container.name])
}

deny[msg] {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[_].livenessProbe
    msg := sprintf("Deployment '%s': container must define a livenessProbe", [input.metadata.name])
}

deny[msg] {
    input.kind == "Deployment"
    not input.spec.template.spec.containers[_].readinessProbe
    msg := sprintf("Deployment '%s': container must define a readinessProbe", [input.metadata.name])
}
package main

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.privileged == true
    msg := sprintf("Deployment '%s': container '%s' must not run privileged", [input.metadata.name, container.name])
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.securityContext.runAsNonRoot
    msg := sprintf("Deployment '%s': container '%s' must set runAsNonRoot=true", [input.metadata.name, container.name])
}

deny[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
    msg := sprintf("Deployment '%s': container '%s' must set allowPrivilegeEscalation=false", [input.metadata.name, container.name])
}

warn[msg] {
    input.kind == "Deployment"
    container := input.spec.template.spec.containers[_]
    not container.securityContext.readOnlyRootFilesystem
    msg := sprintf("Deployment '%s': container '%s' should set readOnlyRootFilesystem=true", [input.metadata.name, container.name])
}
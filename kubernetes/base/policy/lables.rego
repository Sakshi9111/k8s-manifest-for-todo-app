package main

required_labels := {"app", "version", "environment"}

deny[msg] {
    input.kind in {"Deployment", "Service"}
    provided := {label | input.metadata.labels[label]}
    missing := required_labels - provided
    count(missing) > 0
    msg := sprintf("%s '%s': missing required labels: %v", [input.kind, input.metadata.name, missing])
}
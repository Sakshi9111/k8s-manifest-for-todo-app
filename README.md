
---

## 🛠️ Technologies Used

- **Kubernetes**
- **Docker**
- **kubectl**
- **Kustomize**
- **Ingress Controller (NGINX)**
- **Git & GitHub**

---

## ⚙️ Prerequisites

Before deploying this project, ensure you have:

- A running Kubernetes cluster (Minikube, Kind, EKS, AKS, or GKE)
- `kubectl` installed and configured
- Container image of the Todo application available in a container registry
- (Optional) Ingress controller installed on the cluster

---

## 🚀 Deployment Steps

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Sakshi9111/k8s-manifest-for-todo-app.git
cd k8s-manifest-for-todo-app/kubernetes/base/


---

## 🧩 Components Overview

### 🔹 Namespace
- **`namespace.yaml`**
  - Creates a dedicated Kubernetes namespace for the application resources.

---

### 🔹 Django Application
- **`django-deployment.yaml`**
  - Deploys the Django To-Do application
  - Defines container image, environment variables, and replicas

- **`django-service.yaml`**
  - Exposes Django pods internally via a ClusterIP service

---

### 🔹 PostgreSQL Database
- **`postgres-deployment.yaml`**
  - Deploys PostgreSQL database container

- **`postgres-service.yaml`**
  - Exposes PostgreSQL internally for Django to connect

- **`postgres-pv.yaml`**
  - PersistentVolume definition for PostgreSQL data storage

- **`postgres-pvc.yaml`**
  - PersistentVolumeClaim used by PostgreSQL

---

### 🔹 Redis
- **`redis-deployment.yaml`**
  - Deploys Redis (used for caching / background tasks / sessions)

---

### 🔹 Ingress
- **`ingress.yaml`**
  - Exposes Django service externally via Ingress
  - Requires an Ingress Controller (e.g., NGINX)

---

### 🔹 Autoscaling
- **`HPA.yaml`**
  - Horizontal Pod Autoscaler for Django deployment
  - Scales pods based on CPU or memory utilization

---

### 🔹 Kustomize
- **`kustomization.yaml`**
  - Base Kustomize configuration
  - References all Kubernetes resources

- **`kustomization.yaml.bckp`**
  - Backup copy of Kustomize configuration

---

## 🚀 Deployment Instructions

### 1️⃣ Create the namespace
```bash
kubectl apply -f namespace.yaml


---

## 🛠️ Technologies Used

- **Kubernetes**
- **Docker**
- **kubectl**
- **Kustomize**
- **Ingress Controller (NGINX / Traefik / Cloud-specific)**
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

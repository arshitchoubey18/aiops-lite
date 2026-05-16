# AIOps Lite - Kubernetes + AI Log Analysis for 8GB RAM Laptops

> A laptop-friendly AIOps platform that runs Kubernetes, CI/CD, and LLM-powered log analysis without killing your 8GB RAM machine. 
> Built as a staged learning project: start local, upgrade to cloud later.

[![Build Status](https://github.com/YOUR_GITHUB_USERNAME/aiops-lite/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/aiops-lite/actions)

### 🎯 What This Project Does
1. **Simulate failures**: FastAPI app with `/crash` endpoint that throws `ZeroDivisionError`
2. **Detect with AI**: Python script pulls `kubectl logs` → sends to Ollama `phi3` → returns 2-line RCA
3. **Self-heal**: Bash script auto-restarts the deployment when AI detects a crash
4. **CI/CD**: GitHub Actions builds Docker image and pushes to GHCR on every commit

### 🏗️ Architecture - Laptop Version

9 lines hidden
GitHub Push → GitHub Actions → ghcr.io → k3d Cluster → FastAPI Pod
↓
kubectl logs → analyzer.py → Ollama phi3
↓
auto-heal.sh → kubectl rollout restart

Code

### 💻 Laptop Requirements
| Resource | Spec | Why |
| --- | --- | --- |
| CPU | 2 cores minimum | k3d server + agent |
| RAM | 8GB + 4GB swap | Ollama uses ~2GB when running |
| Disk | 10GB free | k3d images + Ollama models |
| OS | Linux / WSL2 / macOS | Tested on Ubuntu 22.04 |

**Critical:** This project is designed to run components sequentially, not all at once. Never run Grafana + Prometheus + Ollama simultaneously on 8GB.

### 🚀 Quick Start - 5 Commands
```bash
# 1. Clone + setup cluster
git clone https://github.com/YOUR_GITHUB_USERNAME/aiops-lite.git && cd aiops-lite
./scripts/setup-k3d.sh

# 2. Build + deploy app  
docker build -t aiops-lite:v1 ./app
k3d image import aiops-lite:v1 -c aiops
kubectl apply -f k8s/

# 3. Install AI model
ollama pull phi3  # or 'ollama pull tinyllama' if RAM is tight

# 4. Run full demo: crash → AI analysis → cleanup
./scripts/crash-test.sh

# 5. Optional: run auto-healer in one terminal
./scripts/auto-heal.sh
# Then in another terminal: curl localhost:8080/crash after port-forward

26 lines hidden
📊 Demo Output
Code
==> Hitting /crash endpoint...
==> Running AI log analyzer...
--- AI ANALYSIS ---
What went wrong: The FastAPI app crashed with ZeroDivisionError at /crash endpoint.
What should I check: Review the /crash handler; it's dividing by zero on purpose for testing.
==> CRASH DETECTED. Triggering rollout restart...
deployment.apps/aiops-app restarted
==> Heal complete.

3 lines hidden
📁 Project Structure
Code
aiops-lite/
├── .github/workflows/build.yml    # CI: build + push to GHCR
├── ai-agent/
│   └── analyzer.py                # Pulls logs → queries Ollama
├── app/
│   ├── main.py                    # FastAPI with /health, /crash
│   ├── Dockerfile                 # Multi-stage, ~50MB image
│   └── requirements.txt
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml            # replicas: 1, limits: 64Mi RAM
│   └── service.yaml
├── scripts/
│   ├── setup-k3d.sh               # Creates light k3d cluster
│   ├── crash-test.sh              # Demo: crash + AI analysis
│   └── auto-heal.sh               # Watches logs, restarts on error
└── README.md

12 lines hidden
🧯 Troubleshooting 8GB RAM Issues
Problem

Fix

OOMKilled on pod

Lower limits.memory: "32Mi" in k8s/deployment.yaml

ollama: connection refused

Run ollama serve or use crash-test.sh which starts it

Laptop freezing

Run sudo swapoff -a && sudo swapon -a + close Chrome

phi3 too slow

Use ollama pull tinyllama and change MODEL in analyzer.py

🗺️ Upgrade Path - From Laptop to Production
Stage

Infrastructure

What to Add

Lite - This Repo

k3d on laptop

Current setup

Cloud v1

AWS EKS t3.medium

Prometheus + Grafana + Loki

Cloud v2

EKS + Karpenter

ArgoCD, AlertManager, PagerDuty

Production

Multi-AZ EKS

Real K8s operator, not bash scripts

🎓 What You Learn Building This
Kubernetes: Deployments, Services, resource limits, liveness probes, kubectl logs
Docker: Multi-stage builds, image optimization for low RAM
CI/CD: GitHub Actions, container registries, GitOps basics
AIOps Concepts: Log analysis, automated RCA, self-healing patterns
LLM Ops: Running Ollama locally, prompt engineering for SRE tasks
Resource Engineering: Making "enterprise" stacks run on consumer hardware
⚠️ Important Disclaimers
auto-heal.sh is a demo script, not a production controller. It polls every 30s and kills Ollama to save RAM.
Don't run this on prod K8s. Use ArgoCD + Prometheus + real operators there.
Ollama models are loaded on-demand. First analysis will be slow while phi3 loads into RAM.
📝 License
MIT - Use this for learning, portfolios, and interviews.
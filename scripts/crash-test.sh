#!/bin/bash
set -e

echo "==> Starting Ollama in background..."
ollama serve &
OLLAMA_PID=$!
sleep 3 # wait for it to boot

echo "==> Hitting /crash endpoint to simulate failure..."
kubectl port-forward -n aiops-lite svc/aiops-svc 8081:80 &
PF_PID=$!
sleep 2

curl -s http://localhost:8081/crash || true
echo ""
echo "==> Waiting 5s for pod to log the error..."
sleep 5

echo "==> Running AI log analyzer..."
python3 ai-agent/analyzer.py

echo "==> Cleaning up..."
kill $PF_PID 2>/dev/null || true
kill $OLLAMA_PID 2>/dev/null || true
echo "==> Done. Ollama stopped to free RAM."

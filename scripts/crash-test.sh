#!/bin/bash
set -e

echo "==> Starting Ollama in background..."
ollama serve &
OLLAMA_PID=$!

sleep 5

# Validate Ollama
if ! kill -0 $OLLAMA_PID 2>/dev/null; then
  echo "❌ Ollama failed to start"
  exit 1
fi

echo "==> Starting port-forward..."
kubectl port-forward -n aiops-lite svc/aiops-svc 8081:80 >/tmp/pf.log 2>&1 &
PF_PID=$!

sleep 4

# Validate port-forward
if ! kill -0 $PF_PID 2>/dev/null; then
  echo "❌ Port-forward failed. Check /tmp/pf.log"
  kill $OLLAMA_PID 2>/dev/null || true
  exit 1
fi

echo "==> Hitting /crash endpoint..."
HTTP_CODE=$(curl -s -o /tmp/crash.out -w "%{http_code}" http://localhost:8081/crash)

echo "HTTP Response Code: $HTTP_CODE"

echo "==> Waiting 5s for logs to stabilize..."
sleep 5

echo "==> Running AI log analyzer..."
python3 ai-agent/analyzer.py

echo "==> Cleaning up..."

kill $PF_PID 2>/dev/null || true
kill $OLLAMA_PID 2>/dev/null || true

echo "==> Done. Clean shutdown completed."

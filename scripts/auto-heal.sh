#!/bin/bash
NAMESPACE="aiops-lite"
LABEL="app=aiops"
COOLDOWN=60 # seconds between restart attempts

echo "==> AIOps Lite Auto-Healer Started. Watching for crashes..."

while true; do
  # 1. Start ollama if not running
  if ! pgrep -f "ollama serve" > /dev/null; then
    echo "==> Starting Ollama..."
    ollama serve &
    sleep 3
  fi

  # 2. Run analyzer and capture output
  ANALYSIS=$(python3 ai-agent/analyzer.py 2>&1)
  echo "$ANALYSIS"
  
  # 3. If AI detected a crash, restart the deployment
  if echo "$ANALYSIS" | grep -qi "ZeroDivisionError\|crashed\|error"; then
    echo "==> CRASH DETECTED. Triggering rollout restart..."
    kubectl rollout restart deployment/aiops-app -n $NAMESPACE
    kubectl rollout status deployment/aiops-app -n $NAMESPACE --timeout=60s
    echo "==> Heal complete. Cooling down for ${COOLDOWN}s..."
    sleep $COOLDOWN
  else
    echo "==> No crash detected. Checking again in 30s..."
    sleep 30
  fi

  # 4. Kill ollama to save RAM between checks
  pkill -f "ollama serve" 2>/dev/null || true
done

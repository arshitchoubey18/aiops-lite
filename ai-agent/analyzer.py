#!/usr/bin/env python3
import subprocess
import requests
import sys
import json
import time

NAMESPACE = "aiops-lite"
LABEL = "app=aiops"
MODEL = "phi3"  # change to "tinyllama" if phi3 is too heavy

def get_pod_logs():
    """Grab last 50 lines from aiops pods"""
    try:
        cmd = f"kubectl logs -n {NAMESPACE} -l {LABEL} --tail=50 --timestamps"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        if result.returncode != 0:
            return f"Error getting logs: {result.stderr}"
        return result.stdout
    except Exception as e:
        return f"Exception: {e}"

def ask_ollama(logs):
    """Send logs to Ollama for analysis"""
    prompt = f"""You are an SRE. Read these Kubernetes pod logs and give a 2-line summary.
First line: What went wrong.
Second line: What should I check or do next.
Be direct. No fluff.

LOGS:
{logs}
"""
    
    try:
        r = requests.post(
            "http://localhost:11434/api/generate",
            json={"model": MODEL, "prompt": prompt, "stream": False},
            timeout=60
        )
        r.raise_for_status()
        return r.json()['response'].strip()
    except requests.exceptions.ConnectionError:
        return "ERROR: Ollama not running. Start it with: ollama serve"
    except Exception as e:
        return f"ERROR: {e}"

if __name__ == "__main__":
    print("==> Fetching logs from K8s...")
    logs = get_pod_logs()
    
    if "ERROR" in logs[:20]:
        print("==> Logs fetched. Asking AI...\n")
        print("--- RAW LOGS ---")
        print(logs[-500:]) # last 500 chars so terminal doesn't flood
        print("\n--- AI ANALYSIS ---")
        print(ask_ollama(logs))
    else:
        print("No errors found in recent logs.")
        print(logs[-300:])

from fastapi import FastAPI
import os
import time

app = FastAPI(title="AIOps Lite App")

@app.get("/")
def root():
    return {"status": "ok", "pod": os.getenv("HOSTNAME"), "message": "AIOps Lite running"}

@app.get("/health")
def health():
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/crash")
def crash():
    """Endpoint to simulate a crash for AIOps testing"""
    print("ERROR: Simulated crash triggered via /crash endpoint")
    return 1 / 0 # ZeroDivisionError on purpose

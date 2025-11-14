from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello from FastAPI on GCP VM!"}

@app.get("/env")
async def get_env():
    return {
        "PROJECT": os.getenv("PROJECT_ID", "unknown"),
        "IMAGE": os.getenv("CONTAINER_IMAGE", "unknown")
    }

@app.post("/echo")
async def echo(payload: dict):
    return {"you_sent": payload}

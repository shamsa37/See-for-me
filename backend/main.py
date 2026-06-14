# from fastapi import FastAPI, UploadFile, File
# import shutil
#
# app = FastAPI()
#
# @app.get("/")
# def home():
#     return {"message": "Backend working"}
#
#
# @app.post("/detect/")
# async def detect(file: UploadFile = File(...)):
#
#     # image save
#     with open("temp.jpg", "wb") as buffer:
#         shutil.copyfileobj(file.file, buffer)
#
#     objects = ["person", "chair"]  # test output
#
#     return {"objects": objects}

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
import numpy as np
import cv2
import logging
import sys
import uvicorn

# ✅ Logger setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="YOLO Scene Detection API",
    redirect_slashes=False
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Load YOLO Model
try:
    print("🔄 Loading YOLO model...")
    model = YOLO("yolov8n.pt")
    logger.info("✅ YOLO model loaded successfully")
    print("✅ YOLO model loaded!")
except Exception as e:
    logger.error(f"❌ Model load failed: {e}")
    print(f"❌ Error loading model: {e}")
    model = None


@app.get("/")
async def health():
    return {"status": "ok", "model": "loaded" if model else "failed"}


@app.post("/detect")
async def detect(file: UploadFile = File(...)):
    try:
        if not file.content_type or not file.content_type.startswith("image/"):
            raise HTTPException(status_code=415, detail="Please upload an image")

        if model is None:
            raise HTTPException(status_code=503, detail="Model not ready")

        file_data = await file.read()
        if not file_data:
            raise HTTPException(status_code=400, detail="Empty file")

        np_arr = np.frombuffer(file_data, np.uint8)
        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if image is None:
            raise HTTPException(status_code=400, detail="Invalid image format")

        logger.info(f"🔍 Processing: {file.filename}")

        results = model(image, conf=0.5)

        object_names = []
        if results and len(results) > 0:
            for box in results[0].boxes:
                class_id = int(box.cls[0])
                class_name = results[0].names[class_id]
                object_names.append(class_name)

        logger.info(f"✅ Detected: {object_names}")

        return {
            "success": True,
            "objects": object_names if object_names else ["Nothing detected"],
            "count": len(object_names)
        }

    except HTTPException as e:
        return JSONResponse(
            status_code=e.status_code,
            content={"success": False, "error": e.detail, "objects": []}
        )
    except Exception as e:
        logger.exception(f"❌ Error: {e}")
        return JSONResponse(
            status_code=500,
            content={"success": False, "error": "Detection failed", "objects": []}
        )


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
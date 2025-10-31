from fastapi import APIRouter, UploadFile, File, Form
import shutil
import os

from databases.store_notes import store_notes

router = APIRouter()

@router.post("/upload_notes")
async def upload_notes(user_id: str = Form(...), file: UploadFile = File(...)):
    """
    Endpoint to upload notes (PDF) for a user.
    """
    # Save uploaded file temporarily
    file_path = f"temp_{user_id}_{file.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Process and store notes
    result = store_notes(user_id, file_path)

    return result

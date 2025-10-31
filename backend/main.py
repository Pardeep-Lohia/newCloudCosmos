import uvicorn
import sys, os
sys.path.append(os.path.dirname(__file__))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.upload_routes import router as upload_router
from routes.query_routes import router as query_router
from routes.quiz_routes import router as quiz_router

app = FastAPI(title="StudyBuddy AI", description="AI-powered study assistant backend")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(upload_router)
app.include_router(query_router)
app.include_router(quiz_router)

@app.get("/")
async def root():
    return {"message": "Welcome to StudyBuddy AI API"}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)

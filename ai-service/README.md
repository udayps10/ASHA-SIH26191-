# Aasha AI Matching Service

This service provides multi-modal ranking for missing person searches. It combines semantic text similarity, face recognition, and broad visual descriptors to rank candidates retrieved from the primary database.

## 🏗️ Architecture

The AI service operates as a pure-function ranking engine in the production matching flow:
1. **Input**: A search query and a bounded list of candidates (from Spring Boot).
2. **Processing**: Compares query fields with each candidate using specialized models.
3. **Output**: A ranked list of candidates with similarity scores and explanations.

**Important**: This service does not query Firestore or external databases in production. It relies entirely on the candidate pool provided in the HTTP request.

## 🧠 Models

- **Text**: `all-MiniLM-L6-v2` for semantic name and detail overlap.
- **Vision (Face)**: `DeepFace` for high-precision facial identity anchors.
- **Vision (Broad)**: `openai/clip-vit-base-patch32` for general visual similarity (clothing, environment).

## 🚀 Running the Service

```bash
# Setup environment
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run with Uvicorn
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## ⚙️ Configuration

The service uses environment variables for optional cloud storage (Cloudinary adapter available but not required for local MinIO/Local deployments).

- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`: (Optional) For cloud storage fallback.

## 🔐 Security & Privacy

- **Sanitization**: Critical record photos are never exposed through this API.
- **Session Bounding**: The service maintains a bounded cache of ranked sessions (`MAX_SESSIONS=100`) to prevent memory leaks.
- **No Probability Claims**: Scores are "Match Scores" (similarity), not identity probabilities or guarantees.

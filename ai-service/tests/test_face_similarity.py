import pytest
import numpy as np
from app.face_similarity import FaceSimilarityService, FaceEmbeddingError, InMemoryFaceEmbeddingCache

@pytest.fixture(scope="module")
def face_service():
    service = FaceSimilarityService()
    try:
        service.load_model()
    except FaceEmbeddingError:
        pytest.skip("InsightFace model failed to load, skipping face tests")
    return service

def test_model_loads(face_service):
    assert face_service.is_ready
    assert face_service.embedding_dimensions == 512

def test_similarity_same_embedding(face_service):
    emb = [0.1] * 512
    sim = face_service.similarity(emb, emb)
    assert sim == pytest.approx(1.0)

def test_similarity_orthogonal(face_service):
    emb_a = [1.0] + [0.0] * 511
    emb_b = [0.0] * 511 + [1.0]
    sim = face_service.similarity(emb_a, emb_b)
    # Cosine 0 scales to (0+1)/2 = 0.5
    assert sim == pytest.approx(0.5)

def test_cache_reuse(face_service):
    cache = InMemoryFaceEmbeddingCache()
    service = FaceSimilarityService(cache=cache)
    # Mock embedding
    emb = [0.5] * 512
    cache.set("test_id", emb)

    # This should return cached without needing to call get_embedding
    # We don't provide a real storage service here to prove it doesn't call it if cached
    result = service.embedding_for_storage("test_id", None)
    assert result == emb

def test_normalization(face_service):
    # InsightFace internal tests would be better, but we can verify our similarity logic
    # expects normalized-ish inputs or handles them.
    emb_unnorm = [2.0] * 512
    emb_norm = [0.1] * 512
    sim = face_service.similarity(emb_unnorm, emb_norm)
    assert sim == pytest.approx(1.0) # Logic uses np.linalg.norm so it handles unnormalized

def test_invalid_dimensions(face_service):
    with pytest.raises(FaceEmbeddingError):
        face_service.similarity([0.1]*512, [0.1]*511)

def test_no_face_detected(face_service):
    # Create a solid black image
    import cv2
    import numpy as np
    black_img = np.zeros((100, 100, 3), dtype=np.uint8)
    _, buffer = cv2.imencode(".jpg", black_img)

    with pytest.raises(FaceEmbeddingError) as excinfo:
        face_service.get_embedding(buffer.tobytes())
    assert "No face detected" in str(excinfo.value)

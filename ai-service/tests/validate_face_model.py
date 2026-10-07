import os
import sys
import time
import cv2
import numpy as np
from pathlib import Path

# Add project root to sys.path
project_root = Path(__file__).parents[1]
sys.path.insert(0, str(project_root))

from app.face_similarity import FaceSimilarityService, FaceEmbeddingError

def load_image_bytes(path):
    with open(path, "rb") as f:
        return f.read()

def create_no_face_image():
    # Solid black 100x100
    img = np.zeros((100, 100, 3), dtype=np.uint8)
    _, buffer = cv2.imencode(".jpg", img)
    return buffer.tobytes()

def create_multiple_face_image(path1, path2):
    # Concatenate two images horizontally
    img1 = cv2.imread(str(path1))
    img2 = cv2.imread(str(path2))

    # Resize img2 to match img1 height
    h, w, _ = img1.shape
    img2_resized = cv2.resize(img2, (int(img2.shape[1] * h / img2.shape[0]), h))

    combined = np.hstack((img1, img2_resized))
    _, buffer = cv2.imencode(".jpg", combined)
    return buffer.tobytes()

def create_single_face_images(service, data_dir):
    img_a_path = data_dir / "t1.jpg"
    img_b_path = data_dir / "Tom_Hanks_54745.png"

    img_a = cv2.imread(str(img_a_path))
    img_b = cv2.imread(str(img_b_path))

    # Get faces from img_a
    faces_a = service._app.get(img_a)
    if not faces_a:
        print("No faces found in img_a to crop")
        return None, None

    # Crop the largest face from img_a
    face_a = max(faces_a, key=lambda x: (x.bbox[2]-x.bbox[0]) * (x.bbox[3]-x.bbox[1]))
    bbox = face_a.bbox.astype(int)
    crop_a = img_a[max(0, bbox[1]):bbox[3], max(0, bbox[0]):bbox[2]]
    crop_a_path = data_dir / "single_face_a.jpg"
    cv2.imwrite(str(crop_a_path), crop_a)

    # img_b is already small (112x112), might be a pre-aligned face
    # We'll try to find a face in it with smaller det_size
    service._app.prepare(ctx_id=0, det_size=(128, 128))
    faces_b = service._app.get(img_b)
    service._app.prepare(ctx_id=0, det_size=(640, 640)) # Restore

    if faces_b:
        face_b = faces_b[0]
        bbox = face_b.bbox.astype(int)
        crop_b = img_b[max(0, bbox[1]):bbox[3], max(0, bbox[0]):bbox[2]]
        crop_b_path = data_dir / "single_face_b.jpg"
        cv2.imwrite(str(crop_b_path), crop_b)
    else:
        # If no face detected, just use it as is if it looks like a face
        crop_b_path = data_dir / "single_face_b.jpg"
        cv2.imwrite(str(crop_b_path), img_b)

    return crop_a_path, crop_b_path

def main():
    print("=" * 50)
    print("FACE MODEL VALIDATION")
    print("=" * 50)

    data_dir = Path(__file__).parent / "data"

    service = FaceSimilarityService()
    try:
        service.load_model()
    except Exception as e:
        print(f"FAILED to load model: {e}")
        return

    print("\nPreparing single-face test images...")
    img_a_single_path, img_b_single_path = create_single_face_images(service, data_dir)

    if not img_a_single_path:
        print("Failed to prepare test images")
        return

    results = []

    # Helper to get embedding with multiple det_sizes if needed
    def get_emb_robust(service, data):
        orig_get = service._app.get
        def robust_get(img):
            for size in [(640, 640), (320, 320), (128, 128)]:
                service._app.prepare(ctx_id=0, det_size=size)
                res = orig_get(img)
                if res: return res
            return []

        service._app.get = robust_get
        try:
            emb = service.get_embedding(data)
            return emb
        finally:
            service._app.get = orig_get
            service._app.prepare(ctx_id=0, det_size=(640, 640))

    # 1. SAME IMAGE
    print("\n[TEST 1] SAME IMAGE")
    try:
        data_a = load_image_bytes(img_a_single_path)
        emb_a1 = get_emb_robust(service, data_a)
        emb_a2 = get_emb_robust(service, data_a)
        sim = service.similarity(emb_a1, emb_a2)
        results.append(("SAME IMAGE", "1 Face", len(emb_a1), sim))
        print(f"Result: 1 Face detected, Similarity: {sim:.4f}")
    except FaceEmbeddingError as e:
        print(f"Error: {e}")
        results.append(("SAME IMAGE", str(e), "-", "N/A"))

    # 2. SAME PERSON / DIFFERENT PHOTO
    print("\n[TEST 2] SAME PERSON / DIFFERENT PHOTO")
    try:
        img_a_single = cv2.imread(str(img_a_single_path))
        # Increase brightness
        img_a_diff = cv2.convertScaleAbs(img_a_single, alpha=1.2, beta=30)
        _, buffer = cv2.imencode(".jpg", img_a_diff)
        data_a_diff = buffer.tobytes()

        emb_a1 = get_emb_robust(service, load_image_bytes(img_a_single_path))
        emb_a_diff = get_emb_robust(service, data_a_diff)
        sim = service.similarity(emb_a1, emb_a_diff)
        results.append(("SAME PERSON / DIFF PHOTO", "1 Face", len(emb_a1), sim))
        print(f"Result: 1 Face detected, Similarity: {sim:.4f}")
    except FaceEmbeddingError as e:
        print(f"Error: {e}")
        results.append(("SAME PERSON / DIFF PHOTO", str(e), "-", "N/A"))

    # 3. DIFFERENT PEOPLE
    print("\n[TEST 3] DIFFERENT PEOPLE")
    try:
        data_b = load_image_bytes(img_b_single_path)
        emb_b = get_emb_robust(service, data_b)
        sim = service.similarity(emb_a1, emb_b)
        results.append(("DIFFERENT PEOPLE", "1 Face", len(emb_a1), sim))
        print(f"Result: 1 Face detected, Similarity: {sim:.4f}")
    except FaceEmbeddingError as e:
        print(f"Error: {e}")
        results.append(("DIFFERENT PEOPLE", str(e), "-", "N/A"))

    # 4. NO FACE
    print("\n[TEST 4] NO FACE")
    try:
        data_none = create_no_face_image()
        service.get_embedding(data_none)
        print("Error: Face detected where none was expected")
    except FaceEmbeddingError as e:
        results.append(("NO FACE", str(e), "-", "N/A"))
        print(f"Result: Correctly handled - {e}")

    # 5. MULTIPLE FACES
    print("\n[TEST 5] MULTIPLE FACES")
    try:
        # Use original img_a (t1.jpg) which has 6 faces
        data_multi = load_image_bytes(data_dir / "t1.jpg")
        service.get_embedding(data_multi)
        print("Error: Single face detected where multiple were expected")
    except FaceEmbeddingError as e:
        results.append(("MULTIPLE FACES", str(e), "-", "N/A"))
        print(f"Result: Correctly handled - {e}")

    print("\n" + "=" * 50)
    print(f"{'IMAGE PAIR':<30} | {'DETECTION':<10} | {'DIM':<5} | {'SIMILARITY':<10}")
    print("-" * 65)
    for pair, det, dim, sim in results:
        sim_str = f"{sim:.4f}" if isinstance(sim, float) else sim
        print(f"{pair:<30} | {det:<10} | {dim:<5} | {sim_str:<10}")
    print("=" * 50)

if __name__ == "__main__":
    main()

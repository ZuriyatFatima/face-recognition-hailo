# Face Recognition Attendance System — Hailo-8L

Face detection + recognition pipeline on Raspberry Pi 5 + Hailo-8L, used as an attendance-logging system: detects faces, matches them against a known-faces database, and logs known/unknown events with timestamps and confidence scores.

## Status: Working pipeline, tested on batch image dataset

The system runs on Hailo's `pipeline_apps/face_recognition` framework and has been exercised against a batch test dataset. Real attendance photos and biometric embeddings have been excluded from this repo for privacy — see "Privacy Note" below.

---

## 1. Pipeline Architecture

Built on Hailo's official `pipeline_apps/face_recognition` app, chaining two on-device models:

1. **Face detection**: `scrfd_2.5g.hef` (SCRFD detector)
2. **Face tracking**: Hailo's built-in tracker (`hailotracker`), assigning stable track IDs across frames
3. **Face recognition / embeddings**: `arcface_mobilefacenet.hef` (ArcFace MobileFaceNet), generating a face embedding vector per detected face
4. **Matching**: embeddings compared against a known-faces database to classify each detection as a known person (with confidence) or unknown

Known-face embeddings are stored as `(name, person_id, sample_count, embedding_json)` rows — see `face_embeddings_schema_example.csv` for the schema (real enrolled embeddings are not included in this repo).

## 2. Attendance Logging

Each recognition event is logged to CSV with a timestamp, tracker ID, and confidence score:

- `attendance_log/known/known_log.csv` — logged when a detected face matches an enrolled person, includes name, global ID, and confidence
- `attendance_log/unknown/unknown_log.csv` — logged when a detected face has no match

(Both files in this repo contain only column headers — real logged rows have been excluded, see below.)

## 3. Batch Testing

Hailo's `pipeline_apps` framework only supports single-image or stream input natively — it doesn't accept a folder of images directly. `run_batch_faces.sh` works around this by looping the single-image pipeline (`face_recognition.py --mode run`) over every file in a test image directory, logging each run's output.

This was used to batch-test the pipeline against a face-detection dataset (Roboflow export, not included in this repo — third-party data). Full run logs are included:
- `day4_dataset_test_log.txt` — batch run log across the full test dataset
- `single_image_debug.txt` — verbose debug log (pipeline string, GStreamer bus messages) for a single test run, useful for understanding the exact pipeline topology

## 4. Privacy Note

This repo intentionally **excludes**:
- Real attendance photos (`attendance_log/known/*.jpg`, `attendance_log/unknown/*.jpg`)
- Real face embeddings and enrollment data (`face_embeddings.csv` and backups)
- Logged attendance rows containing a real person's name, timestamps, and confidence scores

These were removed because they contain biometric data and photos of an identifiable individual. The CSV schema and logging format are demonstrated with headers only; the code and pipeline logic are unaffected by this exclusion.

## 5. Third-Party Data

The batch test dataset (`Face-Detection-7/`, `Face-Detection-sample/`) is a Roboflow-exported face detection dataset, not created by this project, and is not included here.

---

## Repo Contents

- `run_batch_faces.sh` — batch test script (loops pipeline over a folder of images)
- `face_embeddings_schema_example.csv` — schema for the known-faces embedding database (no real data)
- `attendance_log/known/known_log.csv`, `attendance_log/unknown/unknown_log.csv` — attendance log format (headers only)
- `day4_dataset_test_log.txt`, `single_image_debug.txt` — batch test run logs, showing the full GStreamer pipeline and per-image processing

**Not included**: real attendance photos, real face embeddings/enrollment data, third-party test dataset, and the underlying Hailo SDK framework (`hailo_apps`) this project is built on.

## Next Steps

- Document accuracy/false-match rate against the test dataset
- Consider anonymized or synthetic sample data for demonstrating the full pipeline end-to-end

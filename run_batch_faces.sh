#!/bin/bash
# Loops face_recognition.py over every image in a folder, since pipeline_apps
# doesn't support directory input directly (see toolbox.py InputType.IMAGES
# gap between pipeline_apps and standalone_apps).

SAMPLE_DIR=~/hailo-apps/Face-Detection-sample
LOG_FILE=~/hailo-apps/day4_dataset_test_log.txt

cd ~/hailo-apps/hailo_apps/python/pipeline_apps/face_recognition/

echo "Batch run started: $(date)" > "$LOG_FILE"

for img in "$SAMPLE_DIR"/*; do
    echo "=== Processing: $img ===" | tee -a "$LOG_FILE"
    timeout 20 python face_recognition.py --input "$img" --mode run --disable-sync 2>&1 | tee -a "$LOG_FILE"
    echo "" >> "$LOG_FILE"
done

echo "Batch run finished: $(date)" | tee -a "$LOG_FILE"

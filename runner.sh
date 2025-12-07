#!/usr/bin/env sh

#
# Firebase Emulator Suite Runner
#
# This script starts the Firebase emulator suite with configurations set via environment variables.
#
# MIT License - Eric Hacke
#

# Export all environment variables with defaults
export GCP_PROJECT="${GCP_PROJECT:-change-me}"
export RDB_EMULATOR_PORT="${RDB_EMULATOR_PORT:-9000}"
export FIRESTORE_EMULATOR_PORT="${FIRESTORE_EMULATOR_PORT:-8080}"
export UI_EMULATOR_PORT="${UI_EMULATOR_PORT:-4000}"
export UI_ENABLED="${UI_ENABLED:-true}"
export AUTH_EMULATOR_PORT="${AUTH_EMULATOR_PORT:-9099}"
export PUBSUB_EMULATOR_PORT="${PUBSUB_EMULATOR_PORT:-8085}"
export FUNCTIONS_EMULATOR_PORT="${FUNCTIONS_EMULATOR_PORT:-5001}"
export FUNCTIONS_ENABLED="${FUNCTIONS_ENABLED:-false}"
export STORAGE_EMULATOR_PORT="${STORAGE_EMULATOR_PORT:-9199}"
export EMULATORS_HOST="${EMULATORS_HOST:-0.0.0.0}"

# Validate GCP_PROJECT is set to something other than default
if [ "${GCP_PROJECT}" = "change-me" ]; then
  echo "WARNING: GCP_PROJECT is set to default value 'change-me'. Consider setting a project ID."
fi

echo "Starting Firebase Emulator Suite..."
echo "  Project: ${GCP_PROJECT}"
echo "  Firestore: ${EMULATORS_HOST}:${FIRESTORE_EMULATOR_PORT}"
echo "  Auth: ${EMULATORS_HOST}:${AUTH_EMULATOR_PORT}"
echo "  Realtime Database: ${EMULATORS_HOST}:${RDB_EMULATOR_PORT}"
echo "  Storage: ${EMULATORS_HOST}:${STORAGE_EMULATOR_PORT}"
echo "  Pub/Sub: ${EMULATORS_HOST}:${PUBSUB_EMULATOR_PORT}"
if [ "${FUNCTIONS_ENABLED}" = "true" ]; then
  echo "  Functions: ${EMULATORS_HOST}:${FUNCTIONS_EMULATOR_PORT}"
fi
echo "  UI: ${EMULATORS_HOST}:${UI_EMULATOR_PORT} (enabled: ${UI_ENABLED})"

# Generate Firebase configuration from environment variables
node /process_config.js

# Build import flag if baseline data exists
IMPORT_FLAG=""
if [ -d "/firebase/baseline-data" ] && [ "$(ls -A /firebase/baseline-data 2>/dev/null)" ]; then
  echo "Found baseline data, will import from /firebase/baseline-data"
  IMPORT_FLAG="--import /firebase/baseline-data"
fi

# Start Firebase emulators
exec firebase emulators:start --project="${GCP_PROJECT}" ${IMPORT_FLAG}

# Firebase Emulator Suite

A Docker container image for the [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite). Provides a complete local development environment for Firebase services.

Based on [SpineEventEngine/gcp-emulators](https://github.com/SpineEventEngine/gcp-emulators/tree/master/firebase-emulator).

## Supported Emulators

| Service | Default Port | Environment Variable |
|---------|-------------|---------------------|
| Firestore | 8080 | `FIRESTORE_EMULATOR_PORT` |
| Authentication | 9099 | `AUTH_EMULATOR_PORT` |
| Realtime Database | 9000 | `RDB_EMULATOR_PORT` |
| Cloud Storage | 9199 | `STORAGE_EMULATOR_PORT` |
| Cloud Pub/Sub | 8085 | `PUBSUB_EMULATOR_PORT` |
| Cloud Functions | 5001 | `FUNCTIONS_EMULATOR_PORT` |
| Emulator UI | 4000 | `UI_EMULATOR_PORT` |

## Quickstart

```bash
docker run \
  --name firebase-emulator \
  -e "GCP_PROJECT=my-project" \
  -p 8080:8080 \
  -p 9099:9099 \
  -p 9000:9000 \
  -p 9199:9199 \
  -p 8085:8085 \
  -p 5001:5001 \
  -p 4000:4000 \
  -d \
  ehacke/firestore-emulator
```

Or with Docker Compose:

```yaml
version: "3"

services:
  firebase-emulator:
    image: ehacke/firestore-emulator
    environment:
      - GCP_PROJECT=my-project
    ports:
      - "8080:8080"   # Firestore
      - "9099:9099"   # Auth
      - "9000:9000"   # Realtime Database
      - "9199:9199"   # Storage
      - "8085:8085"   # Pub/Sub
      - "5001:5001"   # Functions
      - "4000:4000"   # UI

  app:
    image: your-app-image
    environment:
      - FIRESTORE_EMULATOR_HOST=firebase-emulator:8080
      - FIREBASE_AUTH_EMULATOR_HOST=firebase-emulator:9099
      - FIREBASE_DATABASE_EMULATOR_HOST=firebase-emulator:9000
      - FIREBASE_STORAGE_EMULATOR_HOST=firebase-emulator:9199
      - PUBSUB_EMULATOR_HOST=firebase-emulator:8085
      - GCP_PROJECT=my-project
    depends_on:
      - firebase-emulator
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GCP_PROJECT` | `change-me` | Google Cloud project ID |
| `FIRESTORE_EMULATOR_PORT` | `8080` | Firestore emulator port |
| `AUTH_EMULATOR_PORT` | `9099` | Authentication emulator port |
| `RDB_EMULATOR_PORT` | `9000` | Realtime Database emulator port |
| `STORAGE_EMULATOR_PORT` | `9199` | Cloud Storage emulator port |
| `PUBSUB_EMULATOR_PORT` | `8085` | Pub/Sub emulator port |
| `FUNCTIONS_EMULATOR_PORT` | `5001` | Cloud Functions emulator port |
| `UI_EMULATOR_PORT` | `4000` | Emulator Suite UI port |
| `UI_ENABLED` | `true` | Enable/disable the Emulator UI |
| `EMULATORS_HOST` | `0.0.0.0` | Host address for all emulators |

## Custom Configuration

Mount a custom `firebase.json` to `/firebase/firebase.json` to use your own configuration:

```bash
docker run \
  -v ${PWD}/firebase.json:/firebase/firebase.json \
  -e "GCP_PROJECT=my-project" \
  ehacke/firestore-emulator
```

## Baseline Data

Pre-populate the emulators with baseline data by mounting to `/firebase/baseline-data`:

```bash
# Export data from running emulator
firebase emulators:export ./baseline-data

# Use in container
docker run \
  -v ${PWD}/baseline-data:/firebase/baseline-data \
  -e "GCP_PROJECT=my-project" \
  ehacke/firestore-emulator
```

## Connecting Your Application

Configure your application to connect to the emulators using environment variables:

### Node.js / JavaScript

```javascript
// Firestore
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

// Auth
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

// Realtime Database
process.env.FIREBASE_DATABASE_EMULATOR_HOST = 'localhost:9000';

// Storage
process.env.FIREBASE_STORAGE_EMULATOR_HOST = 'localhost:9199';

// Pub/Sub
process.env.PUBSUB_EMULATOR_HOST = 'localhost:8085';
```

### Python

```python
import os

os.environ['FIRESTORE_EMULATOR_HOST'] = 'localhost:8080'
os.environ['FIREBASE_AUTH_EMULATOR_HOST'] = 'localhost:9099'
os.environ['FIREBASE_DATABASE_EMULATOR_HOST'] = 'localhost:9000'
os.environ['FIREBASE_STORAGE_EMULATOR_HOST'] = 'localhost:9199'
os.environ['PUBSUB_EMULATOR_HOST'] = 'localhost:8085'
```

## Emulator UI

Access the Emulator Suite UI at `http://localhost:4000` to:

- View and edit Firestore data
- Manage Authentication users
- View Realtime Database contents
- Browse Storage files
- Monitor Pub/Sub messages
- View Functions logs

Disable the UI by setting `UI_ENABLED=false`.

## Breaking Changes from v1.x

- Environment variable renamed: `FIRESTORE_PROJECT_ID` → `GCP_PROJECT`
- Volume mount point changed: `/opt/data` → `/firebase`
- Base image changed from `google/cloud-sdk:alpine` to `node:lts-alpine`
- Multiple new ports exposed for additional emulators

## License

MIT License - Eric Hacke

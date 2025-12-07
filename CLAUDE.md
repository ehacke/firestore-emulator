# Firebase Emulator Suite - AI Assistant Guide

This document helps AI assistants understand and debug tests using the Firebase Emulator Suite Docker image.

## Image Overview

**Repository**: `ehacke/firestore-emulator`
**Base**: `node:lts-alpine` with OpenJDK 21
**Reference Implementation**: [SpineEventEngine/gcp-emulators](https://github.com/SpineEventEngine/gcp-emulators/tree/master/firebase-emulator)

### How the Image is Built

1. **Base Image**: `node:lts-alpine` - Provides Node.js runtime for `firebase-tools`
2. **Dependencies**:
   - `python3`, `py3-pip` - Required by some firebase-tools operations
   - `openjdk21-jre` - Required for Firestore, Database, and other emulators
   - `bash` - Shell scripting
3. **Firebase Tools**: Installed globally via npm
4. **Emulator Setup**: Pre-downloads emulator binaries during build:
   - `firebase setup:emulators:database`
   - `firebase setup:emulators:firestore`
   - `firebase setup:emulators:pubsub`
   - `firebase setup:emulators:storage`
   - `firebase setup:emulators:ui`

### Startup Flow

1. `runner.sh` exports environment variables with defaults
2. `process_config.js` generates `/firebase/firebase.json` if not present
3. `firebase emulators:start` launches all configured emulators
4. If `/firebase/baseline-data` contains data, it's imported on startup

## Supported Emulators & Ports

| Emulator | Default Port | Host Env Var |
|----------|-------------|--------------|
| Firestore | 8080 | `FIRESTORE_EMULATOR_HOST` |
| Authentication | 9099 | `FIREBASE_AUTH_EMULATOR_HOST` |
| Realtime Database | 9000 | `FIREBASE_DATABASE_EMULATOR_HOST` |
| Cloud Storage | 9199 | `FIREBASE_STORAGE_EMULATOR_HOST` |
| Cloud Pub/Sub | 8085 | `PUBSUB_EMULATOR_HOST` |
| Cloud Functions | 5001 | (No standard env var) |
| Emulator UI | 4000 | (Web interface only) |

## Environment Variables

### Container Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `GCP_PROJECT` | `change-me` | Project ID used by emulators |
| `FIRESTORE_EMULATOR_PORT` | `8080` | Firestore port |
| `AUTH_EMULATOR_PORT` | `9099` | Auth port |
| `RDB_EMULATOR_PORT` | `9000` | Realtime DB port |
| `STORAGE_EMULATOR_PORT` | `9199` | Storage port |
| `PUBSUB_EMULATOR_PORT` | `8085` | Pub/Sub port |
| `FUNCTIONS_EMULATOR_PORT` | `5001` | Functions port |
| `UI_EMULATOR_PORT` | `4000` | UI port |
| `UI_ENABLED` | `true` | Enable/disable UI |
| `EMULATORS_HOST` | `0.0.0.0` | Bind address |

### Application Connection

Applications connect to emulators by setting these environment variables:

```bash
# Node.js / JavaScript
FIRESTORE_EMULATOR_HOST=localhost:8080
FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
FIREBASE_DATABASE_EMULATOR_HOST=localhost:9000
FIREBASE_STORAGE_EMULATOR_HOST=localhost:9199
PUBSUB_EMULATOR_HOST=localhost:8085
```

## Debugging Tests

### Common Issues

#### 1. "Connection refused" errors

**Cause**: Emulator not running or wrong host/port
**Solution**:
```bash
# Check if emulator is running
docker ps | grep firebase-emulator

# Check emulator logs
docker logs firebase-emulator

# Verify ports are mapped correctly
docker port firebase-emulator
```

#### 2. Tests can't find emulator from Docker Compose

**Cause**: Using `localhost` instead of service name
**Solution**: Use the Docker Compose service name as the host:
```yaml
environment:
  - FIRESTORE_EMULATOR_HOST=firebase-emulator:8080  # NOT localhost:8080
```

#### 3. Emulator data persists between test runs

**Cause**: Volume mounted to `/firebase`
**Solution**:
- Remove the volume between runs: `docker-compose down -v`
- Or don't mount a volume for ephemeral data

#### 4. "Project ID mismatch" errors

**Cause**: Application using different project ID than emulator
**Solution**: Ensure `GCP_PROJECT` matches the project ID in your application config

#### 5. Emulator takes too long to start

**Cause**: First-time emulator downloads or resource constraints
**Solution**:
- The Docker image pre-downloads emulators, so first run should be fast
- Add health checks and depends_on conditions in Docker Compose

### Health Check Example

```yaml
services:
  firebase-emulator:
    image: ehacke/firestore-emulator
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:4000"]
      interval: 5s
      timeout: 10s
      retries: 10
      start_period: 30s
```

### Viewing Emulator State

1. **Emulator UI**: Open `http://localhost:4000` in browser
2. **Container logs**: `docker logs -f firebase-emulator`
3. **Firestore data**: Use the UI's Firestore tab or query via SDK

## Custom Configuration

### Using a Custom firebase.json

Mount your configuration file to override defaults:

```yaml
volumes:
  - ./firebase.json:/firebase/firebase.json
```

The container checks for `/firebase/firebase.json` on startup. If present, it uses that configuration instead of generating one.

### Pre-populating with Baseline Data

1. Export data from a running emulator:
   ```bash
   firebase emulators:export ./baseline-data
   ```

2. Mount the export directory:
   ```yaml
   volumes:
     - ./baseline-data:/firebase/baseline-data
   ```

Data is automatically imported when the container starts.

## Docker Compose Example for Testing

```yaml
version: "3.8"

services:
  firebase-emulator:
    image: ehacke/firestore-emulator
    environment:
      - GCP_PROJECT=test-project
      - UI_ENABLED=false  # Disable UI in CI
    ports:
      - "8080:8080"
      - "9099:9099"
      - "9000:9000"
      - "9199:9199"
      - "8085:8085"
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:8080"]
      interval: 5s
      timeout: 5s
      retries: 10

  test-runner:
    build: .
    environment:
      - FIRESTORE_EMULATOR_HOST=firebase-emulator:8080
      - FIREBASE_AUTH_EMULATOR_HOST=firebase-emulator:9099
      - FIREBASE_DATABASE_EMULATOR_HOST=firebase-emulator:9000
      - FIREBASE_STORAGE_EMULATOR_HOST=firebase-emulator:9199
      - PUBSUB_EMULATOR_HOST=firebase-emulator:8085
      - GCP_PROJECT=test-project
    depends_on:
      firebase-emulator:
        condition: service_healthy
    command: npm test
```

## Files in Container

| Path | Purpose |
|------|---------|
| `/runner.sh` | Entry point script |
| `/process_config.js` | Config generator |
| `/firebase/firebase.json` | Generated or mounted config |
| `/firebase/storage.rules` | Generated storage rules (permissive) |
| `/firebase/firestore.rules` | Generated Firestore rules (permissive) |
| `/firebase/database.rules.json` | Generated RTDB rules (permissive) |
| `/firebase/baseline-data/` | Import data directory |

## Security Rules

By default, the container generates **permissive rules** for local testing:

- **Firestore**: `allow read, write: if true`
- **Storage**: `allow read, write: if true`
- **Realtime Database**: `".read": true, ".write": true`

For custom rules, mount your own `firebase.json` with rule file paths.

## Release Process

This image is **manually built and pushed** to Docker Hub using a script.

### Creating a New Release

1. **Update version** in `package.json` and `Dockerfile` (LABEL "version")
2. **Commit all changes**:
   ```bash
   git add -A
   git commit -m "Release vX.Y.Z"
   ```
3. **Create and push git tag** (for GitHub releases):
   ```bash
   git tag X.Y.Z
   git push origin master
   git push origin X.Y.Z
   ```
4. **Build and push to Docker Hub**:
   ```bash
   ./scripts/build-and-push.sh
   ```

The script publishes both `ehacke/firestore-emulator:X.Y.Z` and `:latest` tags.

### Version Naming

- Use semantic versioning (e.g., `2.0.0`, `2.1.0`)
- Tag name should match `package.json` version
- Historical tags (`171.0`, `183.0`, `198.0`) were based on firebase-tools versions

### Build Script Details

`scripts/build-and-push.sh`:
- Requires a clean git working tree (commit or stash changes first)
- Reads version from `package.json`
- Builds Docker image locally
- Pushes both versioned and `latest` tags to Docker Hub
- Requires Docker Hub authentication (`docker login`)

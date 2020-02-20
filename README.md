# Google Cloud Firestore Emulator

A [Google Cloud Firestore Emulator](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/firestore/) container image. The image is meant to be used for creating an standalone emulator for testing.

This image is a fork from [Perrystallings work](https://github.com/perrystallings/firestore-emulator-docker), which is a fork of [SingularitiesCR work on the Datastore Emulator](https://github.com/SingularitiesCR/datastore-emulator-docker).

## Quickstart

```BASH
docker run \
  --name firestore-emulator \
  -v ${PWD}/firestore-data:/opt/data \
  -e "FIRESTORE_PROJECT_ID=project-test" \
  -p 8080:8080 \
  -d \
  ehacke/firestore-emulator
```

or with compose

```YAML
version: "2"

services:
  firestore-emulator:
    image: ehacke/firestore-emulator
    volumes:
      - firestore-data:/opt/data
    environment:
      - FIRESTORE_PROJECT_ID=project-test
  app:
    image: your-app-image
    environment:
      - FIRESTORE_EMULATOR_HOST=firestore
      - FIRESTORE_PROJECT_ID=project-test
```


## Environment

The following environment variables must be set:

- `FIRESTORE_PROJECT_ID`: The ID of the Google Cloud project for the emulator.

## Networking

The emulator listens on port `8080`

## Connect application with the emulator

The following environment variables need to be set so your application connects to the emulator instead of the production Cloud Firestore environment:

- `FIRESTORE_EMULATOR_HOST`: The listen address used by the emulator (ie. `firestore-emulator:8080`)
- `FIRESTORE_PROJECT_ID`: The ID of the Google Cloud project used by the emulator.

## Data persistance

Data is saved in the `/opt/data` directory on the container.

You can mount a volume on it.

## Custom commands

This image contains a script named `start-firestore` (included in the PATH). This script is used to initialize the Datastore emulator.

### Starting an emulator

By default, the following command is called:

```sh
start-firestore
```
### Starting an emulator with options

This image comes with options. Check [Firestore Emulator GCloud Wide Flags](https://cloud.google.com/sdk/gcloud/reference/beta/emulators/firestore/). `--legacy`, `--data-dir` and `--host-port` are not supported by this image.

## Creating a Firestore emulator with Docker Compose

The easiest way to create an emulator with this image is by using [Docker Compose](https://docs.docker.com/compose). The following snippet can be used as a `docker-compose.yml` for a firestore emulator:

```YAML
version: "2"

services:
  firestore:
    image: ehacke/firestore-emulator
    volumes:
      - firestore-data:/opt/data
    environment:
      - FIRESTORE_PROJECT_ID=project-test
  app:
    image: your-app-image
    environment:
      - FIRESTORE_EMULATOR_HOST=firestore
      - FIRESTORE_PROJECT_ID=project-test
```

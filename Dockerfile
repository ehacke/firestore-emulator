# Firebase Emulator Suite Docker Image
#
# Supports: Firestore, Auth, Realtime Database, Storage, Pub/Sub, Functions, and UI
#
# Based on: https://github.com/SpineEventEngine/gcp-emulators/tree/master/firebase-emulator
#
# MIT License - Eric Hacke

FROM node:lts-alpine AS app-env

LABEL "maintainer"="eric@ehacke.com"
LABEL "version"="2.0.1"
LABEL "description"="Firebase Emulator Suite"

# Install dependencies:
# - python3, py3-pip: Required for some firebase-tools operations
# - openjdk21-jre: Required for emulators (Firestore, etc.)
# - bash: Shell scripting support
RUN apk add --no-cache python3 py3-pip openjdk21-jre bash && \
    npm install -g firebase-tools && \
    firebase setup:emulators:database && \
    firebase setup:emulators:firestore && \
    firebase setup:emulators:pubsub && \
    firebase setup:emulators:storage && \
    firebase setup:emulators:ui && \
    rm -rf /var/cache/apk/* /root/.npm/_cacache

# Environment variables with defaults
ENV GCP_PROJECT="change-me"
ENV RDB_EMULATOR_PORT="9000"
ENV FIRESTORE_EMULATOR_PORT="8080"
ENV UI_EMULATOR_PORT="4000"
ENV UI_ENABLED="true"
ENV AUTH_EMULATOR_PORT="9099"
ENV PUBSUB_EMULATOR_PORT="8085"
ENV FUNCTIONS_EMULATOR_PORT="5001"
ENV FUNCTIONS_ENABLED="false"
ENV STORAGE_EMULATOR_PORT="9199"
ENV EMULATORS_HOST="0.0.0.0"

# Create directories for Firebase data
RUN mkdir -p /firebase/baseline-data

# Volume for persisting emulator data and custom configs
VOLUME /firebase

# Copy scripts
COPY ./runner.sh ./process_config.js /
RUN chmod +x /runner.sh

# Expose all emulator ports
EXPOSE 9000 8080 4000 9099 8085 5001 9199

WORKDIR /firebase

ENTRYPOINT ["/runner.sh"]

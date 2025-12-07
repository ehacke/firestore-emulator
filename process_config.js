#!/usr/bin/env node

/**
 * Firebase Emulator Configuration Generator
 *
 * This script checks for an existing Firebase configuration file at /firebase/firebase.json.
 * If absent, it generates a new configuration based on environment variables.
 *
 * MIT License - Eric Hacke
 */

const fs = require('fs');

const configFolder = '/firebase';
const configPath = `${configFolder}/firebase.json`;

if (!fs.existsSync(configPath)) {
  generateConfig();
} else {
  logCurrentConfig();
}

/**
 * Reads the existing Firebase configuration and logs it.
 */
function logCurrentConfig() {
  const rawContent = fs.readFileSync(configPath);
  const existingConfig = JSON.parse(rawContent);
  console.info('Using existing Firebase configuration:', JSON.stringify(existingConfig, null, 2));
}

/**
 * Generates a Firebase configuration based on environment variables.
 */
function generateConfig() {
  // Generate permissive storage rules for local testing
  const storageRules = `
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
`.trim();

  console.info('Generating Storage security rules (permissive for local testing)');
  fs.writeFileSync(`${configFolder}/storage.rules`, storageRules);

  // Generate Firestore rules (permissive for local testing)
  const firestoreRules = `
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
`.trim();

  console.info('Generating Firestore security rules (permissive for local testing)');
  fs.writeFileSync(`${configFolder}/firestore.rules`, firestoreRules);

  // Generate Realtime Database rules (permissive for local testing)
  const databaseRules = JSON.stringify(
    {
      rules: {
        '.read': true,
        '.write': true,
      },
    },
    null,
    2
  );

  console.info('Generating Realtime Database rules (permissive for local testing)');
  fs.writeFileSync(`${configFolder}/database.rules.json`, databaseRules);

  const firebaseConfig = {
    storage: {
      rules: './storage.rules',
    },
    firestore: {
      rules: './firestore.rules',
    },
    database: {
      rules: './database.rules.json',
    },
    emulators: {
      firestore: {
        port: parseInt(process.env.FIRESTORE_EMULATOR_PORT, 10) || 8080,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
      ui: {
        enabled: process.env.UI_ENABLED !== 'false',
        port: parseInt(process.env.UI_EMULATOR_PORT, 10) || 4000,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
      auth: {
        port: parseInt(process.env.AUTH_EMULATOR_PORT, 10) || 9099,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
      functions: {
        port: parseInt(process.env.FUNCTIONS_EMULATOR_PORT, 10) || 5001,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
      database: {
        port: parseInt(process.env.RDB_EMULATOR_PORT, 10) || 9000,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
      pubsub: {
        port: parseInt(process.env.PUBSUB_EMULATOR_PORT, 10) || 8085,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
      storage: {
        port: parseInt(process.env.STORAGE_EMULATOR_PORT, 10) || 9199,
        host: process.env.EMULATORS_HOST || '0.0.0.0',
      },
    },
  };

  console.info('Generating Firebase configuration:', JSON.stringify(firebaseConfig, null, 2));
  fs.writeFileSync(configPath, JSON.stringify(firebaseConfig, null, 2));
}

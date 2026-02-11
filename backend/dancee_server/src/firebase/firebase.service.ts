import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { Firestore } from 'firebase-admin/firestore';
import * as path from 'path';

/**
 * Service for managing Firebase Admin SDK and Firestore database connection.
 * Initializes Firebase app on module startup and provides Firestore instance.
 */
@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private firestore: Firestore;

  /**
   * Initializes Firebase Admin SDK when the module starts.
   * Uses service account credentials from environment variable or application default credentials.
   */
  async onModuleInit() {
    try {
      // Check if Firebase app is already initialized
      if (admin.apps.length === 0) {
        const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
        const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;

        if (serviceAccountJson) {
          // Initialize with service account JSON from environment variable (for Fly.io, Cloud Run, etc.)
          this.logger.log('Loading service account from environment variable');
          const serviceAccount = JSON.parse(serviceAccountJson);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
          this.logger.log(
            'Firebase initialized with service account from environment',
          );
        } else if (serviceAccountPath) {
          // Resolve path relative to project root (for local development)
          const absolutePath = path.resolve(process.cwd(), serviceAccountPath);
          this.logger.log(`Loading service account from: ${absolutePath}`);

          // Initialize with service account file
          const serviceAccount = require(absolutePath);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
          });
          this.logger.log(
            'Firebase initialized with service account credentials',
          );
        } else {
          // Initialize with application default credentials (for Cloud Run, etc.)
          admin.initializeApp({
            credential: admin.credential.applicationDefault(),
          });
          this.logger.log(
            'Firebase initialized with application default credentials',
          );
        }
      }

      this.firestore = admin.firestore();
      this.logger.log('Firestore connection established');
    } catch (error) {
      this.logger.error('Failed to initialize Firebase', error);
      throw error;
    }
  }

  /**
   * Returns the Firestore database instance.
   */
  getFirestore(): Firestore {
    if (!this.firestore) {
      throw new Error('Firestore not initialized');
    }
    return this.firestore;
  }
}

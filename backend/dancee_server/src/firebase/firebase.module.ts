import { Module, Global } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

/**
 * Global module for Firebase/Firestore integration.
 * Provides Firestore database access throughout the application.
 */
@Global()
@Module({
  providers: [FirebaseService],
  exports: [FirebaseService],
})
export class FirebaseModule {}

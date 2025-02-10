import { initializeApp, cert } from "firebase-admin/app";

export const serviceAccountKey: any = require('../firebase-admin-key.json');
initializeApp({
  credential: cert(serviceAccountKey)
});
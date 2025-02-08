const admin = require('firebase-admin');
const initialData = require('../data/initial_data.json');

// エミュレータに接続
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

// エミュレータ環境では認証情報は不要
admin.initializeApp({
  projectId: 'demo-healthcare-support'
});

const db = admin.firestore();
const auth = admin.auth();

async function createAuthUser() {
  try {
    await auth.createUser({
      uid: 'demo-user',
      email: 'demo@example.com',
      password: 'password123',
      displayName: '鈴木看護師'
    });
    console.log('Authenticationユーザーを作成しました');
  } catch (error) {
    if (error.code === 'auth/uid-already-exists') {
      console.log('ユーザーは既に存在します');
    } else {
      throw error;
    }
  }
}

async function seedData() {
  try {
    // 各コレクションにデータを投入
    for (const [collection, documents] of Object.entries(initialData)) {
      if (Array.isArray(documents)) {
        // users, patientsの場合
        for (const doc of documents) {
          const { id, ...data } = doc;
          await db.collection(collection).doc(id).set(data);
          console.log(`${collection}/${id} を作成しました`);
        }
      } else {
        // todos, chatsの場合
        for (const [docId, data] of Object.entries(documents)) {
          await db.collection(collection).doc(docId).set(data);
          console.log(`${collection}/${docId} を作成しました`);
        }
      }
    }
    console.log('初期データの投入が完了しました');
  } catch (error) {
    console.error('エラーが発生しました:', error);
    process.exit(1);
  }
}

async function main() {
  try {
    await createAuthUser();
    await seedData();
  } catch (error) {
    console.error('エラーが発生しました:', error);
    process.exit(1);
  }
}

main();

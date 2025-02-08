const admin = require('firebase-admin');
const initialData = require('../data/initial_data.json');

// エミュレータに接続
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
admin.initializeApp({ projectId: 'demo-healthcare-support' });
const db = admin.firestore();

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

seedData();

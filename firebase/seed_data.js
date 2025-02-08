const fs = require('fs');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Firebase Admin SDKの初期化
initializeApp({ projectId: 'demo-healthcare-support' });
const db = getFirestore();

// エミュレータに接続
db.settings({
  host: 'localhost:8080',
  ssl: false,
  experimentalForceLongPolling: true,
});

// 初期データ
const data = {
  users: [
    {
      id: 'demo-user',
      name: '鈴木看護師',
      ward: '内科',
      occupation: '看護師',
      email: 'demo@example.com',
      iconIndex: 0,
      createdAt: new Date(),
    },
  ],
  patients: [
    {
      id: 'patient-1',
      basicInfo: {
        id: 'A',
        name: '山田 太郎',
        room: '101',
        bed: 'A',
        gender: 'M',
        ward: '内科',
      },
      medicalHistory: [
        {
          condition: '高血圧',
          startDate: new Date('2020-04-01'),
          details: '服薬治療中',
        },
        {
          condition: '糖尿病',
          startDate: new Date('2021-08-01'),
          details: '食事療法中',
        },
        {
          condition: '腰椎ヘルニア',
          startDate: new Date('2019-01-01'),
          details: '手術実施',
        },
      ],
      currentCondition: '血圧管理中',
    },
  ],
  todos: {
    'patient-1': {
      tasks: [
        {
          title: '血圧測定',
          description: '朝・昼・晩の3回測定',
          deadline: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24時間後
          assignedTo: 'demo-user',
          isCompleted: false,
          createdAt: new Date(),
        },
        {
          title: '服薬確認',
          description: '降圧剤の服用確認',
          deadline: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4時間後
          assignedTo: 'demo-user',
          isCompleted: false,
          createdAt: new Date(),
        },
        {
          title: 'リハビリ',
          description: '歩行訓練 15分',
          deadline: new Date(Date.now() + 6 * 60 * 60 * 1000), // 6時間後
          assignedTo: 'demo-user',
          isCompleted: false,
          createdAt: new Date(),
        },
      ],
    },
  },
  chats: {
    'patient-1': {
      messages: [
        {
          sender: 'demo-doctor',
          message: '患者の血圧が高めです。経過観察をお願いします。',
          timestamp: new Date(Date.now() - 26 * 60 * 60 * 1000), // 26時間前
          quotedEhr: '血圧: 145/95 mmHg\n脈拍: 78/分\n体温: 36.8°C',
          isShared: true,
          reactions: [
            { emoji: '👍', user: 'demo-user' },
            { emoji: '✅', user: 'demo-doctor-2' },
          ],
        },
        {
          sender: 'demo-user',
          message: '承知しました。定期的に測定を行います。',
          timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000), // 1時間前
          isShared: true,
          reactions: [
            { emoji: '👀', user: 'demo-doctor' },
          ],
        },
      ],
      participants: ['demo-user', 'demo-doctor', 'demo-doctor-2'],
      lastMessageTime: new Date(Date.now() - 1 * 60 * 60 * 1000),
    },
  },
};

// データをFirestoreに書き込む
async function seedData() {
  console.log('Seeding data...');

  // ユーザーデータの書き込み
  for (const user of data.users) {
    const { id, ...userData } = user;
    await db.collection('users').doc(id).set(userData);
  }

  // 患者データの書き込み
  for (const patient of data.patients) {
    const { id, ...patientData } = patient;
    await db.collection('patients').doc(id).set(patientData);
  }

  // TODOデータの書き込み
  for (const [patientId, todoData] of Object.entries(data.todos)) {
    for (const task of todoData.tasks) {
      await db.collection('todos').doc(patientId).collection('tasks').add(task);
    }
  }

  // チャットデータの書き込み
  for (const [patientId, chatData] of Object.entries(data.chats)) {
    const { messages, ...chatInfo } = chatData;
    await db.collection('chats').doc(patientId).set(chatInfo);
    for (const message of messages) {
      await db.collection('chats').doc(patientId).collection('messages').add(message);
    }
  }

  console.log('Data seeding completed!');
}

// スクリプトの実行
seedData().catch(console.error);

import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
const serviceAccountKey: any = require('../firebase-admin-key.json');

// Firebase Adminの初期化
initializeApp({
  credential: cert(serviceAccountKey)
});

const firestore = getFirestore();

// Gemini APIの初期化
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');
const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

async function generateSummary(prompt: string): Promise<string> {
  try {
    const result = await model.generateContent(prompt);
    const response = await result.response;
    return response.text();
  } catch (error) {
    console.error('Error generating summary:', error);
    throw error;
  }
}

interface PatientData {
  basicInfo: {
    name: string;
    gender: string;
    room: string;
    bed: string;
  };
  medicalHistory: Array<{
    condition: string;
    startDate: string;
    details: string;
  }>;
  currentCondition: string;
}

export const summarizeCondition = onDocumentUpdated({
  document: 'patients/{patientId}',
  region: 'asia-northeast1',
}, async (event) => {
  console.log('Function triggered for patient:', event.params.patientId);

  const newData = event.data?.after?.data() as PatientData;
  if (!newData) {
    console.log('No new data found');
    return;
  }

  console.log('Processing patient data:', {
    name: newData.basicInfo.name,
    currentCondition: newData.currentCondition
  });

  // 患者情報を構造化
  const patientInfo = {
    基本情報: {
      氏名: newData.basicInfo.name,
      性別: newData.basicInfo.gender === 'M' ? '男性' : '女性',
      病室: `${newData.basicInfo.room}号室 ${newData.basicInfo.bed}`,
    },
    既往歴: newData.medicalHistory.map((history: any) => ({
      疾患: history.condition,
      発症日: new Date(history.startDate).toLocaleDateString('ja-JP'),
      詳細: history.details,
    })),
    現病歴: newData.currentCondition,
  };

  // Gemini APIを使用して要約を生成
  const prompt = `
      以下の患者情報を医療従事者向けに簡潔に要約してください。
      要約は以下のフォーマットに従ってください:
      - 患者概要:
      - 主要な既往歴:
      - 現在の状態:
      - 注意点:

      患者情報:
      ${JSON.stringify(patientInfo, null, 2)}
    `;

  const summary = await generateSummary(prompt);

  if (!event.data?.after?.ref) return;

  // 別コレクションに要約を保存
  await firestore
    .collection('patient_summaries')
    .doc(event.params.patientId)
    .set({
      content: summary
    });
});

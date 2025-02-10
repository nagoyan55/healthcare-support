"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.summarizePatient = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const generative_ai_1 = require("@google/generative-ai");
const firestore_2 = require("firebase-admin/firestore");
// Gemini
const genAI = new generative_ai_1.GoogleGenerativeAI(process.env.GOOGLE_GEMINI_API_KEY || '');
const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
async function generateSummary(prompt) {
    try {
        const result = await model.generateContent(prompt);
        const response = await result.response;
        return response.text();
    }
    catch (error) {
        console.error('Error generating summary:', error);
        throw error;
    }
}
exports.summarizePatient = (0, firestore_1.onDocumentUpdated)({
    document: 'patients/{patientId}',
    region: 'asia-northeast1',
}, async (event) => {
    var _a, _b, _c, _d;
    console.log('Function triggered for patient:', event.params.patientId);
    const newData = (_b = (_a = event.data) === null || _a === void 0 ? void 0 : _a.after) === null || _b === void 0 ? void 0 : _b.data();
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
        既往歴: newData.medicalHistory.map((history) => ({
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
    if (!((_d = (_c = event.data) === null || _c === void 0 ? void 0 : _c.after) === null || _d === void 0 ? void 0 : _d.ref))
        return;
    // 別コレクションに要約を保存
    const firestore = (0, firestore_2.getFirestore)();
    firestore.collection("patient_summaries").doc(event.params.patientId).set({
        content: summary
    });
});
//# sourceMappingURL=summarize.js.map
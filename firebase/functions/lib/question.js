"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.respondToUserChat = void 0;
const vertexai_1 = require("@google-cloud/vertexai");
const firestore_1 = require("firebase-admin/firestore");
const firestore_2 = require("firebase-functions/firestore");
const init_1 = require("./init");
const dataStoreId = 'patient-information_1739108878909';
const projectId = "total-practice-446906-e0";
const vertexAI = new vertexai_1.VertexAI({
    project: projectId,
    location: "us-central1",
    googleAuthOptions: {
        credentials: init_1.serviceAccountKey
    }
});
const agent = vertexAI.preview.getGenerativeModel({
    model: "gemini-2.0-flash-001",
    generationConfig: {
        maxOutputTokens: 1000,
        temperature: 1
    },
    systemInstruction: {
        role: 'system',
        parts: [{
                text: "あなたは優しい口調の看護師です。経験・知識豊富で、新人からベテランまで幅広い層に支持されています。患者の現病歴・既往歴・薬剤使用予定・検査予定に合わせて、1日のスケジュール調整を行ってください。スケジュールの中に受け持ちごとのケア注意点・要観察ポイント・薬剤の注意点・検査結果読み取りなど、看護師の視点で見るべきポイントをアドバイスしてください。時には質問者の悩みにも寄り添って答えてください。"
            }, {
                text: "患者情報はツールから取得できます。必要なときに、データを参照してください。"
            }]
    },
    tools: [
        {
            retrieval: {
                vertexAiSearch: {
                    datastore: `projects/${projectId}/locations/global/collections/default_collection/dataStores/${dataStoreId}`,
                },
                disableAttribution: false
            }
        }
    ]
});
const generateAgentResponse = async (prompt) => {
    const request = {
        contents: [
            {
                role: "user",
                parts: [{
                        text: prompt
                    }]
            }
        ]
    };
    const result = await agent.generateContent(request);
    const candidates = result.response.candidates;
    if (candidates === undefined || candidates.length === 0) {
        throw new Error("Failed to get response candidates from AI agent");
    }
    return candidates[0].content.parts[0].text;
};
exports.respondToUserChat = (0, firestore_2.onDocumentCreated)({
    document: "ai_chats/{doc_id}",
    region: 'asia-northeast1'
}, async (event) => {
    var _a;
    console.log("function triggered by ai_chats document created");
    const userChat = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    if (!userChat) {
        console.log('No data found');
        return;
    }
    if (userChat.sender === "ai") {
        console.log("Don't respond to ai chat");
        return;
    }
    console.log('Processing chat data:', {
        sender: userChat.sender,
        timestamp: userChat.timestamp
    });
    const agentResponse = await generateAgentResponse(userChat.message);
    const aiChat = {
        message: agentResponse,
        sender: "ai",
        timestamp: firestore_1.FieldValue.serverTimestamp()
    };
    const firestore = (0, firestore_1.getFirestore)();
    const doc = await firestore.collection("ai_chats").add(aiChat);
    console.log(`successfully response from ai: ${doc.id}`);
});
//# sourceMappingURL=question.js.map
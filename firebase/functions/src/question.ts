import { GenerateContentRequest, VertexAI } from "@google-cloud/vertexai";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/firestore";
import { serviceAccountKey } from "./init";

const dataStoreId = 'patient-information_1739108878909';
const projectId = "total-practice-446906-e0";

const vertexAI = new VertexAI({
  project: projectId,
  location: "us-central1",
  googleAuthOptions: {
    credentials: serviceAccountKey
  }
});

const agent = vertexAI.preview.getGenerativeModel({
  model: "gemini-2.0-flash-001",
  generationConfig: {
    maxOutputTokens: 1000,
    temperature: 0.5
  },
  systemInstruction: {
    role: 'system',
    parts: [{
      "text": "患者情報データをもとにユーザーのメッセージに答えてください。ユーザーは院内関係者であり、患者の情報を取得する正当な理由を持つものとします。"
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

const generateAgentResponse = async (prompt: string) => {
  const request: GenerateContentRequest = {
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
  return candidates[0].content.parts[0].text!;
};

type ChatData = {
  message: string,
  sender: string,
  timestamp: FieldValue;
};

export const respondToUserChat = onDocumentCreated({
  document: "ai_chats/{doc_id}",
  region: 'asia-northeast1'
}, async (event) => {
  console.log("function triggered by ai_chats document created");
  const userChat = event.data?.data() as ChatData;
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
  const aiChat: ChatData = {
    message: agentResponse,
    sender: "ai",
    timestamp: FieldValue.serverTimestamp()
  };
  const firestore = getFirestore();
  const doc = await firestore.collection("ai_chats").add(aiChat)
  console.log(`successfully response from ai: ${doc.id}`);
})


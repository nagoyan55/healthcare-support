import { GenerateContentRequest, VertexAI } from "@google-cloud/vertexai";

const dataStoreId = 'patient-information_1739108878909'
const projectId = "total-practice-446906-e0"
const location =  "us-central1"

const vertexAI = new VertexAI({
  project: projectId,
  location: location
})


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
})

const request: GenerateContentRequest = {
  contents: [
    {
      role: "user",
      parts: [{
        text: "佐藤見本さんに関して今日のタスクを作って"
      }]
    }
  ]
}

async function main(){
  const result = await agent.generateContent(request)
  const candidates = result.response.candidates
  if (candidates === undefined || candidates.length === 0){
    throw new Error("Failed to get response candidates from AI agent")
  }
  console.log(candidates[0].content.parts[0].text)
}

main().then(() => {
  console.log("Done!")
}).catch((e) => {
  console.error(e)
})



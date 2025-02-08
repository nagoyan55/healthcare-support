# Healthcare Support

看護師向け業務支援アプリケーション。患者情報の閲覧・管理や、医療スタッフ間のコミュニケーションをサポートし、効率的な看護業務の実現を支援します。

## 主な機能

### 1. 患者情報管理
- 患者の基本情報(氏名、病室、ベッド番号など)の閲覧
- 病歴情報の記録と閲覧

### 2. タスク管理
- 患者ケアに関するタスクの作成と割り当て
- タスクの進捗管理と完了確認
- 期限管理とリマインド機能

### 3. チャット機能
- 医療スタッフ間のリアルタイムコミュニケーション
- 患者ごとのチャットルーム
- メッセージへのリアクション機能

## 技術スタック

- **フロントエンド**: Flutter/Dart
- **バックエンド**: Firebase (Authentication, Cloud Firestore)
- **開発環境**: Docker

## 開発環境のセットアップ

### 必要なツール

1. Flutter SDK
2. Docker Desktop
3. Node.js

### セットアップ手順

1. リポジトリのクローン
```bash
git clone [repository-url]
cd healthcare_support
```

2. Flutter依存関係のインストール
```bash
flutter pub get
```

3. Firebaseエミュレータ用のパッケージインストール
```bash
cd firebase
npm install
cd ..
```

## アプリケーションの起動方法

### 1. Firebaseエミュレータの起動

```bash
docker-compose up -d
```

エミュレータUIは以下のURLでアクセス可能です:
- http://localhost:4000

### 2. 初期データの投入

```bash
cd firebase
node scripts/seed.js
cd ..
```

### 3. Flutterアプリの起動

```bash
flutter run
```

## デモアカウント

以下のアカウントで動作確認が可能です:

- **メールアドレス**: demo@example.com
- **パスワード**: password123
- **表示名**: 鈴木看護師

## 初期データについて

### データ構造

1. **patients**: 患者情報
   - 基本情報(氏名、病室、ベッド番号)
   - 病歴
   - 現在の状態

2. **users**: ユーザー情報
   - 看護師情報
   - アカウント設定

3. **todos**: タスク情報
   - 患者ケアのタスク
   - 担当者の割り当て
   - 期限と進捗状況

4. **chats**: チャット情報
   - メッセージ履歴
   - 参加者情報
   - リアクション情報

### サンプルデータ

初期データには以下が含まれています:
- サンプル患者データ
- 看護師データ
- タスクデータ
- チャットデータ

# プロジェクト詳細

## 基本情報

- プロジェクト名: RNGNewAuraNotifier
- 言語: C# (.NET 9.0)
- プラットフォーム: Windows
- ターゲットフレームワーク: .NET 9.0-windows10.0.17763.0
- インターフェース: Windows Forms (システムトレイアプリケーション)

## プロジェクト概要

RNGNewAuraNotifierは、VR Chat内の「Elite's RNG Land」というワールドで取得したAura（特殊エフェクト）を監視し、新しいAuraが獲得された際にWindows Toast通知とDiscord Webhookを通じて通知するWindowsデスクトップアプリケーションです。アプリケーションはシステムトレイに常駐し、VR Chatのログファイルを監視して動作します。

## 技術スタック

### フレームワークと言語

- C# (.NET 9.0)
- Windows Forms - GUIフレームワーク
- Windows 10 SDK - Windows 10のAPI機能を利用するためのSDK

### 依存パッケージ

- **Discord.Net.Webhook** (v3.17.4) - Discordへの通知機能を提供
- **Microsoft.Toolkit.Uwp.Notifications** (v7.1.3) - Windows Toast通知を実装
- **Newtonsoft.Json** (v13.0.3) - JSONデータの処理
- **System.Text.Json** - 設定ファイルのJSON処理（.NET標準ライブラリ）

### ビルドと配布

- **PublishSingleFile** - 単一の実行ファイルとして配布
- **DebugType: embedded** - デバッグ情報を実行ファイルに埋め込み
- **Windows 10 (10.0.17763.0以上)** - 対象OSバージョン

### パッケージマネージャー

- NuGet - .NET依存パッケージ管理

## ディレクトリ構成

```text
RNGNewAuraNotifier/
├── .github/                     # GitHub CI/CD設定
│   ├── review-config.yml        # レビュー設定
│   └── workflows/               # GitHub Actions ワークフロー
│       ├── ci.yml               # CI設定
│       ├── release.yml          # リリース設定
│       └── review.yml           # レビュー設定
├── bin/                         # ビルド出力
│   └── Publish/                 # パブリッシュ出力
├── RNGNewAuraNotifier/          # メインプロジェクト
│   ├── Core/                    # コアロジック
│   │   ├── Aura/               # Aura関連クラス
│   │   ├── Config/             # アプリ設定
│   │   ├── Json/               # JSON処理
│   │   ├── Notification/       # 通知処理
│   │   └── VRChat/             # VRChatログ処理
│   ├── Properties/              # プロジェクトプロパティ
│   ├── Resources/               # アプリリソース
│   │   ├── AppIcon.ico         # アプリアイコン
│   │   └── Auras.json          # Auraデータ
│   ├── UI/                      # ユーザーインターフェース
│   │   ├── Settings/           # 設定画面
│   │   └── TrayIcon/           # システムトレイアイコン
│   └── RNGNewAuraNotifier.csproj # プロジェクトファイル
├── RNGNewAuraNotifier.Updater/  # アップデーター（不完全）
│   ├── bin/                    # ビルド出力
│   └── obj/                    # 中間ファイル
└── RNGNewAuraNotifier.sln       # ソリューションファイル
```

## 主要機能

1. **VRChatログ監視機能**
   - VRChatのログディレクトリを監視し、新しいログファイルを検出
   - 正規表現を使用して「Elite's RNG Land」ワールドでのAura取得ログを解析

2. **通知機能**
   - Windows Toast通知 - ローカル通知
   - Discord Webhook - リモート通知

3. **設定管理**
   - VRChatログディレクトリのカスタマイズ
   - Discord WebhookのURL設定
   - 設定のJSON保存機能

4. **システムトレイ統合**
   - アプリケーションをシステムトレイに常駐
   - 設定画面へのアクセス
   - アプリケーション終了

## 設計パターンとアーキテクチャ

1. **イベント駆動型アーキテクチャ** - ログファイルの監視とイベント発火による処理
2. **サービスパターン** - 機能ごとにサービスクラスを分離（通知、検出など）
3. **シングルトンパターン** - 設定管理などで利用
4. **静的ファクトリーメソッド** - `Aura.GetAura()`などの静的生成メソッド

## CI/CD

- **GitHub Actions** - ビルド、テスト、リリース自動化
  - ビルドワークフロー（ci.yml）
  - リリースワークフロー（release.yml）
  - 依存関係の自動更新（renovate）

## 注意点と課題

1. **アップデーター機能の不完全さ** - RNGNewAuraNotifier.Updaterプロジェクトのフォルダは存在しますが、完全な実装が見当たりません
2. **バージョン管理** - プロジェクトバージョンは「0.0.0」に設定されており、開発段階と考えられます
3. **テストコードの欠如** - 自動テストの実装が見当たりません

## 開発環境

- Visual Studio (VisualStudioVersion = 17.13.35919.96 d17.13)
- .NET 9.0 SDK
- Windows 10 (10.0.17763.0以上)
- NuGetパッケージマネージャ

## ライセンス

MITライセンスで公開されています。

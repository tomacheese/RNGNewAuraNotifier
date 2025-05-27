# プロジェクト詳細

## 概要

RNGNewAuraNotifierは、VRChat内の「Elite's RNG Land」というワールドで獲得したAura（オーラ）の通知を行うWindows向けのアプリケーションです。このアプリケーションは、VRChatのログファイルを監視し、新しいAuraを獲得した際にWindows Toast通知とDiscord Webhookを通じて通知を行います。

## 技術スタック

- **言語**: C# (.NET 9.0)
- **フレームワーク**: .NET 9.0 for Windows 10 (バージョン 10.0.17763.0以上)
- **UI**: Windows Forms (SystemTray Icon)
- **ビルドツール**: MSBuild (.NET SDK)
- **通知システム**:
  - Windows Toast通知 (Microsoft.Toolkit.Uwp.Notifications)
  - Discord Webhook (Discord.Net.Webhook)
- **JSON処理**: Newtonsoft.Json
- **コード分析**: StyleCop.Analyzers

## プロジェクト構造

プロジェクトは主に2つのコンポーネントに分かれています：

1. **RNGNewAuraNotifier**: メインアプリケーション
   - システムトレイアイコンを表示
   - VRChatのログファイルを監視
   - Aura獲得時の通知処理
   - 設定管理

2. **RNGNewAuraNotifier.Updater**: アップデーター
   - GitHubからの最新リリースのダウンロード
   - アプリケーションの更新処理

## 主要な機能

- VRChatのログファイル監視
- 新しいAura獲得の検出
- Windows Toast通知
- Discord Webhook通知
- アプリケーションの自動更新
- 設定の管理（ログディレクトリ、Discord Webhook URL等）

## 依存パッケージ

### RNGNewAuraNotifier (メインアプリケーション)

- **Discord.Net.Webhook** (v3.17.4): Discord通知機能
- **Microsoft.Toolkit.Uwp.Notifications** (v7.1.3): Windows Toast通知
- **Newtonsoft.Json** (v13.0.3): JSON処理
- **StyleCop.Analyzers** (v1.1.118): コード分析・スタイルチェック

### RNGNewAuraNotifier.Updater (アップデーター)

- **Newtonsoft.Json** (v13.0.3): JSON処理
- **StyleCop.Analyzers** (v1.1.118): コード分析・スタイルチェック

## ディレクトリ構造

主要なディレクトリとファイルの構造は以下の通りです：

### RNGNewAuraNotifier (メインアプリケーション)

- **Core/**: コアロジック
  - **Aura/**: Aura関連クラス
  - **Config/**: 設定管理
  - **Json/**: JSON処理
  - **Notification/**: 通知機能
  - **Updater/**: アップデート機能
  - **VRChat/**: VRChat関連機能
- **Resources/**: リソースファイル
  - **AppIcon.ico**: アプリケーションアイコン

  - **Auras.json**: Aura情報のJSONデータ
- **UI/**: ユーザーインターフェース
  - **Settings/**: 設定画面

  - **TrayIcon/**: システムトレイアイコン

### RNGNewAuraNotifier.Updater (アップデーター)

- **Core/**: アップデーターのコアロジック
  - **AppConstants.cs**: アプリケーション定数

  - **GitHubReleaseService.cs**: GitHub API関連
  - **ReleaseInfo.cs**: リリース情報
  - **SemanticVersion.cs**: セマンティックバージョン処理
  - **UpdaterHelper.cs**: アップデートヘルパー

## ビルド設定

両プロジェクトは以下の共通設定を持ちます：

- .NET 9.0 for Windows 10 (10.0.17763.0以上)
- Nullableの有効化
- 単一ファイル発行 (PublishSingleFile)
- デバッグ情報の埋め込み
- unsafe ブロックの許可

## テスト

プロジェクト内に専用のテストコードは見つかりませんでした。現状はテストフレームワークを使用したユニットテストやインテグレーションテストは実装されていないようです。

## ライセンス

プロジェクトはMITライセンスの下で公開されています。ライセンス所有者はTomachiで、著作権は2025年となっています。

## CI/CD

GitHub Actionsを使用してCI/CDが構成されています：

- **.github/workflows/ci.yml**: 継続的インテグレーション
- **.github/workflows/release.yml**: リリース処理
- **.github/workflows/review.yml**: コードレビュー

これらによりビルド、テスト、リリースの自動化が行われています。

# RNGNewAuraNotifier プロジェクト詳細

## プロジェクト概要

RNGNewAuraNotifierは、VRChatのワールド「[Elite's RNG Land](https://vrchat.com/home/world/wrld_50a4de63-927a-4d7e-b322-13d715176ef1)」で獲得したAura（特殊効果）を、Windows Toastと Discord Webhookを使用して通知するWindowsデスクトップアプリケーションです。

VRChatのログファイルを監視し、新しいAuraを獲得した際に自動的に通知を送信することで、ユーザーがゲーム内で新たなアイテムを獲得したことをリアルタイムで確認できます。

## 技術スタック

### 使用言語

- C# (.NET 9.0)

### フレームワーク

- .NET Windows Forms（デスクトップUI）
- Windows 10 Universal Windows Platform (UWP) API（Windows Toast通知用）

### 依存パッケージ・ライブラリ

- **Microsoft.Toolkit.Uwp.Notifications** (v7.1.3) - Windows Toast通知実装のために使用
- **Discord.Net.Webhook** (v3.17.4) - Discord Webhook通知の送信に使用
- **Newtonsoft.Json** (v13.0.3) - JSONデータの処理に使用

### パッケージマネージャ

- NuGet

### ターゲットプラットフォーム

- Windows 10 (バージョン 10.0.17763.0以上)

## ディレクトリ構成

```
RNGNewAuraNotifier/
├── README.md                        # プロジェクト概要
├── renovate.json                    # 依存関係の自動更新設定
├── RNGNewAuraNotifier.sln           # ソリューションファイル
├── RNGNewAuraNotifier/              # メインプロジェクト
│   ├── Program.cs                   # エントリーポイント
│   ├── RNGNewAuraNotifier.csproj    # プロジェクト設定
│   ├── Core/                        # コア機能
│   │   ├── AppConstant.cs           # アプリケーション定数
│   │   ├── RNGNewAuraController.cs  # メインコントローラー
│   │   ├── Aura/                    # Aura関連
│   │   │   ├── Aura.cs              # Auraモデル
│   │   │   └── NewAuraDetectionService.cs # Aura検出サービス
│   │   ├── Config/                  # 設定関連
│   │   │   ├── AppConfig.cs         # アプリ設定管理
│   │   │   └── ConfigData.cs        # 設定データモデル
│   │   ├── Json/                    # JSON処理関連
│   │   │   └── JsonData.cs          # JSON操作クラス
│   │   ├── Notification/            # 通知関連
│   │   │   ├── DiscordNotificationService.cs # Discord通知
│   │   │   └── UwpNotificationService.cs     # Windows通知
│   │   └── VRChat/                  # VRChat連携関連
│   │       ├── AuthenticatedDetectionService.cs # 認証検出
│   │       ├── LogWatcher.cs        # ログ監視
│   │       └── VRChatUser.cs        # ユーザーモデル
│   ├── Resources/                   # リソースファイル
│   │   ├── AppIcon.ico              # アプリケーションアイコン
│   │   └── Auras.json               # Aura情報データ
│   ├── UI/                          # ユーザーインターフェース
│   │   ├── Settings/                # 設定画面
│   │   │   ├── SettingsForm.cs      # 設定画面ロジック
│   │   │   └── SettingsForm.Designer.cs # 設定画面デザイン
│   │   └── TrayIcon/                # システムトレイアイコン
│   │       └── TrayIcon.cs          # トレイアイコン実装
│   └── Properties/                  # プロジェクトプロパティ
│       └── Resources.Designer.cs    # リソース定義
└── RNGNewAuraNotifier.Updater/      # アップデーター機能
```

## 主要機能

1. **VRChatログファイルの監視**
   - LogWatcher クラスによる指定ディレクトリのログファイル監視
   - ファイル変更検出とリアルタイム読み取り

2. **新規Aura獲得の検出**
   - 正規表現によるログパターンのマッチング
   - NewAuraDetectionService による Aura 獲得イベントの検出
   - 既知の Aura 情報とのマッチング (Auras.json)

3. **通知機能**
   - Windows Toast 通知 (UwpNotificationService)
   - Discord Webhook 通知 (DiscordNotificationService)
   - 通知メッセージのカスタマイズ

4. **システムトレイアプリケーション**
   - トレイアイコンによる常駐アプリケーション
   - 設定メニューへのアクセス
   - アプリケーション終了制御

5. **設定管理**
   - VRChat ログディレクトリの設定
   - Discord Webhook URL の設定
   - 設定データの JSON ファイルへの保存

6. **自動アップデート機能**
   - GitHub リリースから最新バージョン検出
   - アプリケーションの自動更新
   - アップデートスキップオプション

## テストコード

プロジェクト内にはテストコードが確認できませんでした。単体テストやインテグレーションテストのプロジェクト・ファイルは存在しません。テスト自動化の仕組みも見当たらないため、機能検証は手動で行われていると推測されます。

## ビルドと公開

- Single File 公開（PublishSingleFile=true）によるデプロイ
- ビルド成果物：RNGNewAuraNotifier.exe（メインアプリケーション）
- Windows 10.0.17763.0 以上をターゲットにしたデスクトップアプリケーション
- 埋め込みデバッグ情報（DebugType=embedded）
- アイコンファイル（Resources/AppIcon.ico）の適用
- バージョン情報管理（0.0.0 デフォルト値）

## 例外処理

- グローバル例外ハンドラによる未処理例外のキャプチャ
- ThreadException、UnhandledException、UnobservedTaskException のハンドリング
- エラー発生時の詳細なログ出力
- GitHub Issues へのバグ報告用リンク自動生成

## パフォーマンスと効率性

- ログファイルの変更検出にはFileSystemWatcherを使用
- 初回読み込み時の通知抑制による通知スパム防止
- 優先度の低いAura（Tier 5）の通知を抑制
- 非同期処理（Task）によるUI応答性の維持

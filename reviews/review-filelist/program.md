# プログラムコード

プロジェクトには以下のプログラムファイルが含まれています：

## メインアプリケーション (RNGNewAuraNotifier)

### エントリーポイント
- [RNGNewAuraNotifier/Program.cs](../RNGNewAuraNotifier/Program.cs) - アプリケーションのエントリーポイント

### コアモジュール
- [RNGNewAuraNotifier/Core/AppConstants.cs](../RNGNewAuraNotifier/Core/AppConstants.cs) - アプリケーション定数
- [RNGNewAuraNotifier/Core/RNGNewAuraController.cs](../RNGNewAuraNotifier/Core/RNGNewAuraController.cs) - メインコントローラー

#### Auraモジュール
- [RNGNewAuraNotifier/Core/Aura/Aura.cs](../RNGNewAuraNotifier/Core/Aura/Aura.cs) - Auraモデル
- [RNGNewAuraNotifier/Core/Aura/NewAuraDetectionService.cs](../RNGNewAuraNotifier/Core/Aura/NewAuraDetectionService.cs) - Aura検出サービス

#### 設定モジュール
- [RNGNewAuraNotifier/Core/Config/AppConfig.cs](../RNGNewAuraNotifier/Core/Config/AppConfig.cs) - アプリケーション設定
- [RNGNewAuraNotifier/Core/Config/ConfigData.cs](../RNGNewAuraNotifier/Core/Config/ConfigData.cs) - 設定データモデル

#### JSONモジュール
- [RNGNewAuraNotifier/Core/Json/JsonData.cs](../RNGNewAuraNotifier/Core/Json/JsonData.cs) - JSON操作クラス

#### 通知モジュール
- [RNGNewAuraNotifier/Core/Notification/DiscordNotificationService.cs](../RNGNewAuraNotifier/Core/Notification/DiscordNotificationService.cs) - Discord通知サービス
- [RNGNewAuraNotifier/Core/Notification/UwpNotificationService.cs](../RNGNewAuraNotifier/Core/Notification/UwpNotificationService.cs) - Windows通知サービス

#### アップデートモジュール
- [RNGNewAuraNotifier/Core/Updater/UpdateChecker.cs](../RNGNewAuraNotifier/Core/Updater/UpdateChecker.cs) - アップデートチェック

#### VRChatモジュール
- [RNGNewAuraNotifier/Core/VRChat/AuthenticatedDetectionService.cs](../RNGNewAuraNotifier/Core/VRChat/AuthenticatedDetectionService.cs) - 認証検出サービス
- [RNGNewAuraNotifier/Core/VRChat/LogWatcher.cs](../RNGNewAuraNotifier/Core/VRChat/LogWatcher.cs) - ログ監視
- [RNGNewAuraNotifier/Core/VRChat/VRChatUser.cs](../RNGNewAuraNotifier/Core/VRChat/VRChatUser.cs) - VRChatユーザーモデル

### UI
- [RNGNewAuraNotifier/UI/TrayIcon/TrayIcon.cs](../RNGNewAuraNotifier/UI/TrayIcon/TrayIcon.cs) - システムトレイアイコン
- [RNGNewAuraNotifier/UI/Settings/SettingsForm.cs](../RNGNewAuraNotifier/UI/Settings/SettingsForm.cs) - 設定フォーム
- [RNGNewAuraNotifier/UI/Settings/SettingsForm.Designer.cs](../RNGNewAuraNotifier/UI/Settings/SettingsForm.Designer.cs) - 設定フォームデザイナー

### リソース
- [RNGNewAuraNotifier/Properties/Resources.Designer.cs](../RNGNewAuraNotifier/Properties/Resources.Designer.cs) - リソース定義

## アップデーターアプリケーション (RNGNewAuraNotifier.Updater)

### エントリーポイント
- [RNGNewAuraNotifier.Updater/Program.cs](../RNGNewAuraNotifier.Updater/Program.cs) - アップデーターのエントリーポイント

### コアモジュール
- [RNGNewAuraNotifier.Updater/Core/AppConstants.cs](../RNGNewAuraNotifier.Updater/Core/AppConstants.cs) - アプリケーション定数
- [RNGNewAuraNotifier.Updater/Core/GitHubReleaseService.cs](../RNGNewAuraNotifier.Updater/Core/GitHubReleaseService.cs) - GitHubリリース処理
- [RNGNewAuraNotifier.Updater/Core/ReleaseInfo.cs](../RNGNewAuraNotifier.Updater/Core/ReleaseInfo.cs) - リリース情報
- [RNGNewAuraNotifier.Updater/Core/SemanticVersion.cs](../RNGNewAuraNotifier.Updater/Core/SemanticVersion.cs) - セマンティックバージョン処理
- [RNGNewAuraNotifier.Updater/Core/UpdaterHelper.cs](../RNGNewAuraNotifier.Updater/Core/UpdaterHelper.cs) - アップデートヘルパー
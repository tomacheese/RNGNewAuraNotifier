# プログラムファイルリスト

以下のC#ソースコードファイルをレビュー対象とします：

## プログラムコア

- `/RNGNewAuraNotifier/Program.cs` - アプリケーションのエントリポイント
- `/RNGNewAuraNotifier/Core/AppConstant.cs` - アプリケーション定数
- `/RNGNewAuraNotifier/Core/RNGNewAuraController.cs` - メインコントローラー

## Aura関連

- `/RNGNewAuraNotifier/Core/Aura/Aura.cs` - Auraモデル
- `/RNGNewAuraNotifier/Core/Aura/NewAuraDetectionService.cs` - Aura検出サービス

## 設定関連

- `/RNGNewAuraNotifier/Core/Config/AppConfig.cs` - アプリケーション設定
- `/RNGNewAuraNotifier/Core/Config/ConfigData.cs` - 設定データ

## JSON処理

- `/RNGNewAuraNotifier/Core/Json/JsonData.cs` - JSONデータ処理

## 通知関連

- `/RNGNewAuraNotifier/Core/Notification/DiscordNotificationService.cs` - Discord通知
- `/RNGNewAuraNotifier/Core/Notification/UwpNotificationService.cs` - Windows Toast通知

## VRChat関連

- `/RNGNewAuraNotifier/Core/VRChat/AuthenticatedDetectionService.cs` - ユーザー認証検出
- `/RNGNewAuraNotifier/Core/VRChat/LogWatcher.cs` - ログ監視
- `/RNGNewAuraNotifier/Core/VRChat/VRChatUser.cs` - VRChatユーザーモデル

## UI関連

- `/RNGNewAuraNotifier/UI/Settings/SettingsForm.cs` - 設定画面
- `/RNGNewAuraNotifier/UI/Settings/SettingsForm.Designer.cs` - 設定画面デザイナー
- `/RNGNewAuraNotifier/UI/TrayIcon/TrayIcon.cs` - システムトレイアイコン

## リソース

- `/RNGNewAuraNotifier/Properties/Resources.Designer.cs` - リソースデザイナー

# SettingsForm.cs レビュー

## 概要

このファイルは、アプリケーションの設定画面のフォームクラスを実装しています。VRChatのログディレクトリとDiscord WebhookのURLを設定し、保存する機能を提供しています。また、設定が変更されていた場合にフォーム終了時に保存確認ダイアログを表示する機能も実装しています。

## コードの良い点

- 各メソッドに適切なXMLドキュメントコメントが付与されています
- フォームが閉じられる際に、変更された設定の保存を確認するダイアログが表示されます
- タイマーを使用して監視対象のファイルパスを定期的に更新しています
- リソース（タイマー）が適切に解放されています
- 例外処理が適切に実装されており、エラーメッセージがユーザーに表示されます

## 改善の余地がある点

### 1. タイマーイベントハンドラのラムダ式

**問題点**: タイマーのTickイベントがラムダ式で直接実装されていますが、これはコードの分離性と再利用性を低下させます。

**改善案**: イベントハンドラをメソッドとして分離します。

```csharp
private void OnLoad(object sender, EventArgs e)
{
    // 設定ファイルから値を読み込む
    textBoxLogDir.Text = AppConfig.LogDir;
    if (string.IsNullOrWhiteSpace(textBoxLogDir.Text))
    {
        textBoxLogDir.Text = Program.Controller?.GetLogDirectory() ?? string.Empty;
    }
    textBoxDiscordWebhookUrl.Text = AppConfig.DiscordWebhookUrl;

    // 1秒ごとに監視対象パスの更新を行う
    _timer.Tick += OnTimerTick;
    _timer.Start();

    _lastSavedLogDir = textBoxLogDir.Text.Trim();
    _lastSavedDiscordWebhookUrl = textBoxDiscordWebhookUrl.Text.Trim();
}

/// <summary>
/// タイマーのTickイベントハンドラ
/// </summary>
private void OnTimerTick(object? sender, EventArgs e)
{
    textBoxWatchingFilePath.Text = Program.Controller?.GetLastReadFilePath() ?? string.Empty;
}
```

### 2. 静的な依存関係の使用

**問題点**: `Program.Controller`のような静的なフィールドに直接アクセスしており、テスト容易性が低下しています。

**改善案**: 依存性注入を導入して、外部の依存関係を注入できるようにします。

```csharp
internal partial class SettingsForm : Form
{
    private readonly Timer _timer = new()
    {
        Interval = 1000 // 1 sec
    };
    private string _lastSavedLogDir = string.Empty;
    private string _lastSavedDiscordWebhookUrl = string.Empty;
    private readonly IRNGNewAuraController _controller;
    private readonly INotificationService _notificationService;

    public SettingsForm(IRNGNewAuraController controller, INotificationService notificationService)
    {
        InitializeComponent();
        _controller = controller;
        _notificationService = notificationService;
    }

    // IRNGNewAuraControllerインターフェースを定義
    public interface IRNGNewAuraController : IDisposable
    {
        string GetLogDirectory();
        string GetLastReadFilePath();
        void Start();
    }

    // INotificationServiceインターフェースを定義
    public interface INotificationService
    {
        void Notify(string title, string message);
    }

    // Save メソッドの修正例
    private bool Save()
    {
        try
        {
            AppConfig.LogDir = textBoxLogDir.Text;
            AppConfig.DiscordWebhookUrl = textBoxDiscordWebhookUrl.Text;

            _controller.Dispose();
            // コントローラーの再作成とスタートは、このクラスの外部で行うべき
            // ...

            _lastSavedLogDir = textBoxLogDir.Text;
            _lastSavedDiscordWebhookUrl = textBoxDiscordWebhookUrl.Text;

            _notificationService.Notify("Settings Saved", "Settings have been saved successfully.");
            return true;
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error saving settings: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }
    }
}
```

### 3. ユーザー入力の検証

**問題点**: ユーザーが入力したURLやパスの検証が行われていません。

**改善案**: 入力値の検証を追加して、無効な値が保存されないようにします。

```csharp
private bool ValidateInputs()
{
    // ログディレクトリの検証
    var logDir = textBoxLogDir.Text.Trim();
    if (string.IsNullOrWhiteSpace(logDir))
    {
        MessageBox.Show("Log directory cannot be empty.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        return false;
    }

    if (!Directory.Exists(logDir))
    {
        var result = MessageBox.Show(
            "The specified log directory does not exist. Do you want to create it?",
            "Directory Not Found",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question);
            
        if (result == DialogResult.Yes)
        {
            try
            {
                Directory.CreateDirectory(logDir);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to create directory: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
        }
        else
        {
            return false;
        }
    }

    // Discord WebhookのURL検証
    var webhookUrl = textBoxDiscordWebhookUrl.Text.Trim();
    if (!string.IsNullOrWhiteSpace(webhookUrl))
    {
        if (!Uri.TryCreate(webhookUrl, UriKind.Absolute, out var uri) ||
            (uri.Scheme != "http" && uri.Scheme != "https") ||
            !uri.Host.Contains("discord.com"))
        {
            MessageBox.Show("The Discord webhook URL is invalid. It should be a valid Discord webhook URL.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }
    }

    return true;
}

private bool Save()
{
    if (!ValidateInputs())
    {
        return false;
    }

    try
    {
        // 以下は既存のコード
        // ...
    }
    catch (Exception ex)
    {
        // ...
    }
}
```

### 4. UIの応答性の向上

**問題点**: 設定の保存やコントローラーの再起動が、UIスレッドで直接行われており、UIの応答性が低下する可能性があります。

**改善案**: 時間がかかる処理を別スレッドで実行します。

```csharp
private async Task<bool> SaveAsync()
{
    if (!ValidateInputs())
    {
        return false;
    }

    try
    {
        // UIの状態を更新
        saveButton.Enabled = false;
        saveButton.Text = "Saving...";
        
        // 設定を保存
        AppConfig.LogDir = textBoxLogDir.Text;
        AppConfig.DiscordWebhookUrl = textBoxDiscordWebhookUrl.Text;

        // 時間のかかる処理を別スレッドで実行
        await Task.Run(() =>
        {
            Program.Controller?.Dispose();
            Program.Controller = new RNGNewAuraController(textBoxLogDir.Text);
            Program.Controller.Start();
        });

        _lastSavedLogDir = textBoxLogDir.Text;
        _lastSavedDiscordWebhookUrl = textBoxDiscordWebhookUrl.Text;

        UwpNotificationService.Notify("Settings Saved", "Settings have been saved successfully.");
        return true;
    }
    catch (Exception ex)
    {
        MessageBox.Show($"Error saving settings: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
    }
    finally
    {
        // UIの状態を元に戻す
        saveButton.Enabled = true;
        saveButton.Text = "Save";
    }
}

private async void OnSaveButtonClicked(object sender, EventArgs e) => await SaveAsync();
```

## セキュリティリスク

### 1. Discord Webhook URLの保護

**問題点**: Discord Webhook URLがプレーンテキストで表示・保存されています。このURLを知っていれば誰でもWebhookを使用できるため、セキュリティリスクとなります。

**改善案**: Webhook URLをマスク表示し、保存時に暗号化します。

```csharp
// AppConfig.csの修正例
public static string DiscordWebhookUrl
{
    get => Decrypt(GetConfigValue("DiscordWebhookUrl"));
    set => SetConfigValue("DiscordWebhookUrl", Encrypt(value));
}

private static string Encrypt(string plainText)
{
    // 暗号化処理を実装
    // ...
}

private static string Decrypt(string cipherText)
{
    // 復号処理を実装
    // ...
}

// SettingsForm.csの修正例
private void OnLoad(object sender, EventArgs e)
{
    // ...
    textBoxDiscordWebhookUrl.PasswordChar = '*'; // URLをマスク表示
    // ...
}
```

## パフォーマンス上の懸念

- タイマーの更新間隔が1秒に設定されていますが、これはUIの更新としては頻繁すぎる可能性があります。更新間隔を長くするか、更新が必要な場合のみ行うように変更することでCPU使用率を低減できます

## 単体テスト容易性

- UIコンポーネントであるため、単体テストが難しい構造になっています
- 静的な依存関係（`Program.Controller`、`UwpNotificationService`）の使用により、テスト容易性がさらに低下しています
- 依存性注入を導入して外部依存を抽象化することで、テスト容易性を向上させることができます

## 可読性と命名

- メソッド名と変数名は明確で分かりやすいです
- コメントが適切に記述されており、コードの理解が容易です
- `_lastSavedLogDir`と`_lastSavedDiscordWebhookUrl`のような変数名は、その目的が明確に伝わっています

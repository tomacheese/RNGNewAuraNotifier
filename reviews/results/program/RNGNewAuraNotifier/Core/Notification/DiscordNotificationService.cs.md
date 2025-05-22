# DiscordNotificationService.cs レビュー結果

## ファイルの概要

`DiscordNotificationService.cs`はDiscord Webhookを使用して通知を送信するためのサービスクラスです。テキストメッセージと埋め込みフィールドの2種類の通知形式をサポートしています。

## コードの良い点

1. 非同期メソッドが適切に実装され、`ConfigureAwait(false)`が使われている
2. DiscordのWebhookクライアントが`using`ステートメントで適切に破棄されている
3. URLが空の場合は早期リターンして処理を省略している
4. 埋め込みフィールドを使用した柔軟な通知形式をサポートしている
5. VRChatユーザー情報の有無に応じた条件分岐が適切に実装されている

## 改善点

### 1. コードの重複

二つのNotifyメソッドに多くの重複コードがあります。

**改善案**:

```csharp
private static EmbedBuilder CreateBaseEmbed(string title, VRChatUser? vrchatUser)
{
    var embed = new EmbedBuilder
    {
        Title = title,
        Footer = new EmbedFooterBuilder
        {
            Text = $"{AppConstant.AppName} {AppConstant.AppVersion.Major}.{AppConstant.AppVersion.Minor}.{AppConstant.AppVersion.Build}",
        },
        Color = new Color(0x00, 0xFF, 0x00),
        Timestamp = DateTimeOffset.UtcNow,
    };

    if (vrchatUser != null)
    {
        embed.Author = new EmbedAuthorBuilder
        {
            Name = vrchatUser.UserName,
            Url = $"https://vrchat.com/home/user/{vrchatUser.UserId}",
        };
    }
    
    return embed;
}

public static async Task Notify(string title, string message, VRChatUser? vrchatUser)
{
    var url = AppConfig.DiscordWebhookUrl;
    if (string.IsNullOrEmpty(url)) return;

    using var client = new DiscordWebhookClient(url);
    var embed = CreateBaseEmbed(title, vrchatUser);
    embed.Description = message;
    
    await client.SendMessageAsync(text: "", embeds: [embed.Build()]).ConfigureAwait(false);
}

public static async Task Notify(string title, List<(string Name, string Value, bool Inline)>? fields, VRChatUser? vrchatUser)
{
    var url = AppConfig.DiscordWebhookUrl;
    if (string.IsNullOrEmpty(url)) return;

    using var client = new DiscordWebhookClient(url);
    var embed = CreateBaseEmbed(title, vrchatUser);
    
    if (fields != null)
    {
        foreach ((var name, var value, var inline) in fields)
        {
            embed.AddField(name, value, inline);
        }
    }
    
    await client.SendMessageAsync(text: "", embeds: [embed.Build()]).ConfigureAwait(false);
}
```

### 2. エラーハンドリングの不足

外部サービスへの通信には常にエラーの可能性があるため、例外処理が必要です。

**改善案**:

```csharp
public static async Task Notify(string title, string message, VRChatUser? vrchatUser)
{
    var url = AppConfig.DiscordWebhookUrl;
    if (string.IsNullOrEmpty(url)) return;

    try
    {
        using var client = new DiscordWebhookClient(url);
        var embed = CreateBaseEmbed(title, vrchatUser);
        embed.Description = message;
        
        await client.SendMessageAsync(text: "", embeds: [embed.Build()]).ConfigureAwait(false);
    }
    catch (Exception ex)
    {
        // ログ出力
        Console.WriteLine($"Failed to send Discord notification: {ex.Message}");
    }
}
```

### 3. 通知失敗時のフォールバックメカニズムがない

Discordへの通知が失敗した場合の代替手段がありません。

**改善案**:

```csharp
public static async Task Notify(string title, string message, VRChatUser? vrchatUser)
{
    var url = AppConfig.DiscordWebhookUrl;
    if (string.IsNullOrEmpty(url))
    {
        // URLが設定されていない場合はログだけ出力
        Console.WriteLine($"Discord webhook URL is not set. Message not sent: {title}");
        return;
    }

    try
    {
        using var client = new DiscordWebhookClient(url);
        var embed = CreateBaseEmbed(title, vrchatUser);
        embed.Description = message;
        
        await client.SendMessageAsync(text: "", embeds: [embed.Build()]).ConfigureAwait(false);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Failed to send Discord notification: {ex.Message}");
        
        // フォールバック: 通知をローカルに保存
        try
        {
            var logDir = Path.Combine(Environment.CurrentDirectory, "logs");
            Directory.CreateDirectory(logDir);
            var logFile = Path.Combine(logDir, "failed_notifications.log");
            var logEntry = $"[{DateTime.Now}] {title}\n{message}\n-----\n";
            File.AppendAllText(logFile, logEntry);
        }
        catch
        {
            // ログ保存も失敗した場合は何もできない
        }
    }
}
```

### 4. ハードコードされた値の存在

RGB値（0x00, 0xFF, 0x00）やフッターテキストのフォーマットがハードコードされています。

**改善案**:

```csharp
// 定数として定義
private static readonly Color SuccessColor = new(0x00, 0xFF, 0x00);
private static readonly string FooterTextFormat = "{0} {1}.{2}.{3}";

private static EmbedBuilder CreateBaseEmbed(string title, VRChatUser? vrchatUser)
{
    var embed = new EmbedBuilder
    {
        Title = title,
        Footer = new EmbedFooterBuilder
        {
            Text = string.Format(
                FooterTextFormat, 
                AppConstant.AppName, 
                AppConstant.AppVersion.Major, 
                AppConstant.AppVersion.Minor, 
                AppConstant.AppVersion.Build
            ),
        },
        Color = SuccessColor,
        Timestamp = DateTimeOffset.UtcNow,
    };
    
    // ...残りのコード
}
```

### 5. インターフェースの欠如

テスト容易性を向上させるためのインターフェース定義がありません。

**改善案**:

```csharp
public interface INotificationService
{
    Task Notify(string title, string message, VRChatUser? user = null);
    Task Notify(string title, List<(string Name, string Value, bool Inline)>? fields, VRChatUser? user = null);
}

internal class DiscordNotificationService : INotificationService
{
    private readonly string _webhookUrl;
    
    public DiscordNotificationService(string webhookUrl)
    {
        _webhookUrl = webhookUrl;
    }
    
    // 既存のメソッドを非静的に変更
    public async Task Notify(string title, string message, VRChatUser? vrchatUser)
    {
        if (string.IsNullOrEmpty(_webhookUrl)) return;
        
        // ...残りのコード
    }
    
    // ...他のメソッド
}

// 使用例:
var service = new DiscordNotificationService(AppConfig.DiscordWebhookUrl);
await service.Notify("Test", "Hello world", user);
```

## セキュリティの懸念点

1. Discord WebhookのURLを直接使用しているため、URLの安全性（有効期限、権限など）に依存しています
2. Discordの制限（レート制限など）を考慮した実装がありません

## パフォーマンスの懸念点

1. 毎回新しいWebhookクライアントを作成しているため、頻繁に通知を送信する場合はオーバーヘッドが大きくなる可能性があります
2. 同期的なAPI呼び出しのブロッキングが発生する可能性があります

## 全体的な評価

DiscordNotificationServiceは基本的な機能を提供していますが、コードの重複削減、エラーハンドリングの強化、テスト容易性の向上のために改良の余地があります。特に外部サービスとの通信においては、一時的な障害やエラーに対する対策が重要です。インターフェースの導入とDIパターンの採用により、より柔軟でテスト可能なコードになるでしょう。

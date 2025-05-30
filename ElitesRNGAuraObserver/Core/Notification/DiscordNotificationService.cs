using Discord;
using Discord.Webhook;
using ElitesRNGAuraObserver.Core.VRChat;
using Color = Discord.Color;

namespace ElitesRNGAuraObserver.Core.Notification;

/// <summary>
/// DiscordのWebhookを使用してメッセージを送信するサービス
/// </summary>
internal static class DiscordNotificationService
{
    /// <summary>
    /// DiscordのWebhookを使用してメッセージを送信する
    /// </summary>
    /// <param name="discordWebhookUrl">送信するWebhookURL</param>
    /// <param name="title">メッセージのタイトル</param>
    /// <param name="vrchatUser">VRChatのユーザー情報</param>
    /// <param name="message">メッセージの内容</param>
    /// <param name="fields">メッセージのフィールド群</param>
    /// <returns>DiscordのWebhookを使用してメッセージを送信する非同期操作を表すタスク</returns>
    public static async Task NotifyAsync(string discordWebhookUrl, string title, VRChatUser? vrchatUser, string? message = null, List<(string Name, string Value, bool Inline)>? fields = null)
    {
        var url = discordWebhookUrl;
        if (string.IsNullOrEmpty(url)) return;

        using var client = new DiscordWebhookClient(url);
        var embed = new EmbedBuilder
        {
            Title = title,
            Footer = new EmbedFooterBuilder
            {
                Text = $"{AppConstants.DisplayAppName} {AppConstants.AppVersionString}",
            },
            Color = new Color(0x00, 0xFF, 0x00),
            Timestamp = DateTimeOffset.UtcNow,
        };

        if (!string.IsNullOrEmpty(message))
        {
            embed.Description = message;
        }

        if (vrchatUser != null)
        {
            embed.Author = new EmbedAuthorBuilder
            {
                Name = vrchatUser.UserName,
                Url = $"https://vrchat.com/home/user/{vrchatUser.UserId}",
            };
        }

        if (fields != null)
        {
            foreach ((var name, var value, var inline) in fields)
            {
                embed.AddField(name, value, inline);
            }
        }

        await client.SendMessageAsync(text: string.Empty, embeds: [embed.Build()]).ConfigureAwait(false);
    }
}

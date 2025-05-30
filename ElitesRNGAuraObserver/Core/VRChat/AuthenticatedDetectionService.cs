using System.Text.RegularExpressions;

namespace ElitesRNGAuraObserver.Core.VRChat;

/// <summary>
/// 認証されたユーザーのログインを検出するサービス
/// </summary>
internal partial class AuthenticatedDetectionService
{
    /// <summary>
    /// 新しいユーザーログインを検出したときに発生するイベント
    /// </summary>
    /// <param name="vrchatUser">ログインしているVRChatユーザーの情報</param>
    /// <param name="isFirstReading">初回読み込みかどうか</param>
    public event Action<VRChatUser, bool> OnDetected = (vrchatUser, isFirstReading) => { };

    /// <summary>
    /// VRChatログイン時のログパターン
    /// </summary>
    /// <example>2025.04.19 14:10:45 Debug      -  User Authenticated: Tomachi (usr_0b83d9be-9852-42dd-98e2-625062400acc)</example>
    [GeneratedRegex(@"(?<datetime>[0-9]{4}\.[0-9]{2}.[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}) (?<Level>.[A-z]+) *- *User Authenticated: (?<UserName>.+) \((?<UserId>usr_[A-z0-9\-]+)\)")]
    private static partial Regex UserAuthenticatedRegex();

    /// <summary>
    /// ログウォッチャー
    /// </summary>
    private readonly LogWatcher _watcher;

    /// <summary>
    /// 新しいユーザーログインを検出するサービス
    /// </summary>
    /// <param name="watcher">ログウォッチャー</param>
    public AuthenticatedDetectionService(LogWatcher watcher)
    {
        _watcher = watcher;
        _watcher.OnNewLogLine += HandleLogLine;
    }

    /// <summary>
    /// ログ行を処理する
    /// </summary>
    /// <param name="line">ログ行</param>
    /// <param name="isFirstReading">初回読み込みかどうか</param>
    private void HandleLogLine(string line, bool isFirstReading)
    {
        Match matchUserLogPattern = UserAuthenticatedRegex().Match(line);
        Console.WriteLine($"AuthenticatedDetectionService.HandleLogLine/matchUserLogPattern.Success: {matchUserLogPattern.Success}");
        if (!matchUserLogPattern.Success)
        {
            return;
        }

        var userName = matchUserLogPattern.Groups["UserName"].Value;
        var userId = matchUserLogPattern.Groups["UserId"].Value;
        OnDetected.Invoke(new VRChatUser
        {
            UserName = userName,
            UserId = userId,
        }, isFirstReading);
    }
}

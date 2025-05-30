using System.Reflection;

namespace ElitesRNGAuraObserver.Core;

/// <summary>
/// アプリケーションの定数を格納するクラス
/// </summary>
internal static class AppConstants
{
    /// <summary>
    /// アプリケーションの表示名
    /// </summary>
    public const string DisplayAppName = "Elite's RNG Aura Observer";

    /// <summary>
    /// アセンブリ名
    /// </summary>
    public static readonly string AssemblyName = Assembly.GetExecutingAssembly().GetName().Name ?? string.Empty;

    /// <summary>
    /// アプリケーションバージョンの文字列
    /// </summary>
    public static readonly string AppVersionString = (Assembly.GetExecutingAssembly().GetName().Version ?? new Version(0, 0, 0)).ToString(3); // Major.Minor.Patch

    /// <summary>
    /// VRChatのデフォルトログディレクトリのパス
    /// </summary>
    public static readonly string VRChatLogDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "AppData", "LocalLow", "VRChat", "VRChat");

    /// <summary>
    /// アプリケーションの設定ディレクトリのパス
    /// </summary>
    public static readonly string ApplicationConfigDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), GitHubRepoOwner, GitHubRepoName);

    /// <summary>
    /// GitHub リポジトリのオーナー名
    /// </summary>
    public const string GitHubRepoOwner = "tomacheese";

    /// <summary>
    /// GitHub リポジトリ名
    /// </summary>
    public const string GitHubRepoName = "ElitesRNGAuraObserver";
}

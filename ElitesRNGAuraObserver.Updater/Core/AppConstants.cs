using System.Reflection;

namespace ElitesRNGAuraObserver.Updater.Core;

/// <summary>
/// アプリケーションの定数を格納するクラス
/// </summary>
internal static class AppConstants
{
    /// <summary>
    /// アプリケーション名
    /// </summary>
    public static readonly string AssemblyName = Assembly.GetExecutingAssembly().GetName().Name ?? string.Empty;

    /// <summary>
    /// アプリケーションバージョンの文字列
    /// </summary>
    public static readonly string AppVersionString = (Assembly.GetExecutingAssembly().GetName().Version ?? new Version(0, 0, 0)).ToString(3); // Major.Minor.Patch
}

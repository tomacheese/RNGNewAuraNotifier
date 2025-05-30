using ElitesRNGAuraObserver.Core;
using ElitesRNGAuraObserver.UI.Settings;
using Application = System.Windows.Forms.Application;

namespace ElitesRNGAuraObserver.UI.TrayIcon;

/// <summary>
/// トレイアイコンのクラス
/// </summary>
internal class TrayIcon : ApplicationContext
{
    /// <summary>
    /// トレイアイコン
    /// </summary>
    private readonly NotifyIcon _trayIcon = new();

    /// <summary>
    /// 設定画面
    /// </summary>
    private SettingsForm _settingsForm = new();

    /// <summary>
    /// コンストラクタ
    /// </summary>
    public TrayIcon()
    {
        var contextMenu = new ContextMenuStrip();
        contextMenu.Items.Add("Settings", null, ShowSettings);
        contextMenu.Items.Add("Exit", null, Exit);

        _trayIcon.Icon = Properties.Resources.AppIcon;
        _trayIcon.ContextMenuStrip = contextMenu;
        _trayIcon.Text = AppConstants.DisplayAppName;
        _trayIcon.Visible = true;
        _trayIcon.MouseClick += (sender, e) =>
        {
            if (e.Button == MouseButtons.Left)
            {
                ShowSettings(sender, e);
            }
        };
    }

    /// <summary>
    /// 設定画面を表示する
    /// </summary>
    private void ShowSettings(object? sender, EventArgs e)
    {
        if (_settingsForm == null || _settingsForm.IsDisposed)
        {
            _settingsForm = new SettingsForm();
        }

        _settingsForm.Show();
        _settingsForm.BringToFront();
    }

    /// <summary>
    /// アプリケーションを終了する
    /// </summary>
    private void Exit(object? sender, EventArgs e)
    {
        _trayIcon.Visible = false;
        _settingsForm?.Close();
        _settingsForm?.Dispose();
        _trayIcon.Dispose();
        Application.Exit();
    }

    /// <summary>
    /// アンマネージリソースを解放するかどうかを示します。
    /// </summary>
    /// <param name="disposing">
    /// true の場合、マネージリソースとアンマネージリソースの両方を解放します。
    /// false の場合、アンマネージリソースのみを解放します。
    /// </param>
    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _trayIcon.Dispose();
            _settingsForm?.Dispose();
        }

        base.Dispose(disposing);
    }
}

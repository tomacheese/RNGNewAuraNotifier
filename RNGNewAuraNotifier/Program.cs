using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Toolkit.Uwp.Notifications;
using RNGNewAuraNotifier.Core;
using RNGNewAuraNotifier.Core.Config;
using RNGNewAuraNotifier.Core.Updater;
using RNGNewAuraNotifier.UI.TrayIcon;

namespace RNGNewAuraNotifier;

internal static partial class Program
{
    public static RNGNewAuraController? Controller;

    [LibraryImport("kernel32.dll", SetLastError = true)]
    [DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool AllocConsole();

    [STAThread]
    public static async Task Main()
    {
        if (ToastNotificationManagerCompat.WasCurrentProcessToastActivated())
        {
            // トースト通知から起動された場合、なにもしない
            ToastNotificationManagerCompat.Uninstall();
            return;
        }

        Application.ThreadException += (s, e) => OnException(e.Exception, "ThreadException");
        Thread.GetDomain().UnhandledException += (s, e) => OnException((Exception)e.ExceptionObject, "UnhandledException");
        TaskScheduler.UnobservedTaskException += (s, e) => OnException(e.Exception, "UnobservedTaskException");

        var cmds = Environment.GetCommandLineArgs();
        if (cmds.Any(cmd => cmd.Equals("--debug")))
        {
            AllocConsole();
            Console.SetOut(new StreamWriter(Console.OpenStandardOutput()) { AutoFlush = true });
            Console.OutputEncoding = Encoding.UTF8;
        }

        Console.WriteLine("Program.Main");

        if (cmds.Any(cmd => cmd.Equals("--skip-update")))
        {
            Console.WriteLine("Skip update check");
        }
        else
        {
            var existsUpdate = await UpdateChecker.Check().ConfigureAwait(false);
            if (existsUpdate)
            {
                Console.WriteLine("Found update. Exiting...");
                return;
            }
        }

        ApplicationConfiguration.Initialize();

        // ログディレクトリのパス対象が存在しない場合はメッセージを出してリセットする
        if (!Directory.Exists(AppConfig.LogDir))
        {
            MessageBox.Show(
                "The log directory does not exist.\n" +
                "Log directory settings return to default value.",
                "Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);

            AppConfig.LogDir = AppConstants.VRChatDefaultLogDirectory;
        }

        Controller = new RNGNewAuraController(AppConfig.LogDir);
        Controller.Start();

        Application.ApplicationExit += (s, e) =>
        {
            Console.WriteLine("Program.ApplicationExit");
            Controller?.Dispose();
            ToastNotificationManagerCompat.Uninstall();
        };

        Application.Run(new TrayIcon());
    }

    public static void OnException(Exception e, string exceptionType)
    {
        Console.WriteLine($"Exception: {exceptionType}");
        Console.WriteLine($"Message: {e.Message}");
        Console.WriteLine($"InnerException: {e.InnerException?.Message}");
        Console.WriteLine($"StackTrace: {e.StackTrace}");

        var errorDetailAndStacktrace = "----- Error Details -----\n" +
            e.Message + "\n" +
            e.InnerException?.Message + "\n" +
            "\n" +
            "----- StackTrace -----\n" +
            e.StackTrace + "\n";

        DialogResult result = MessageBox.Show(
            "An error has occurred and the operation has stopped.\n" +
            "It would be helpful if you could report this bug using GitHub issues!\n" +
            "https://github.com/tomacheese/RNGNewAuraNotifier/issues\n" +
            "\n" +
            errorDetailAndStacktrace +
            "\n" +
            "Click OK to open the Create GitHub issue page.\n" +
            "Click Cancel to close this application.",
            $"Error ({exceptionType})",
            MessageBoxButtons.OKCancel,
            MessageBoxIcon.Error);

        if (result == DialogResult.OK)
        {
            Process.Start(new ProcessStartInfo()
            {
                FileName = "https://github.com/tomacheese/RNGNewAuraNotifier/issues/new?body=" + Uri.EscapeDataString(errorDetailAndStacktrace),
                UseShellExecute = true,
            });
        }
        Application.Exit();
    }
}

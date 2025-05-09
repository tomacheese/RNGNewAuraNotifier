using System.Diagnostics;
using System.Runtime.InteropServices;
using RNGNewAuraNotifier.Core;
using RNGNewAuraNotifier.Core.Config;
using RNGNewAuraNotifier.UI.TrayIcon;

namespace RNGNewAuraNotifier;
internal static partial class Program
{
    public static RNGNewAuraController? Controller;

    [LibraryImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static partial bool AllocConsole();

    [STAThread]
    static void Main()
    {
        Application.ThreadException += (s, e) => OnException(e.Exception, "ThreadException");
        Thread.GetDomain().UnhandledException += (s, e) => OnException((Exception)e.ExceptionObject, "UnhandledException");
        TaskScheduler.UnobservedTaskException += (s, e) => OnException(e.Exception, "UnobservedTaskException");

        var cmds = Environment.GetCommandLineArgs();
        if (cmds.Any(cmd => cmd.Equals("--debug")))
        {
            AllocConsole();
            Console.SetOut(new StreamWriter(Console.OpenStandardOutput()) { AutoFlush = true });
        }

        Console.WriteLine("Program.Main");
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

            AppConfig.LogDir = AppConstant.VRChatDefaultLogDirectory;
        }

        Controller = new RNGNewAuraController(AppConfig.LogDir);
        Controller.Start();

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
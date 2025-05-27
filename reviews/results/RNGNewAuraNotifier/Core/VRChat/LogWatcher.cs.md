# LogWatcher.csのレビュー

## 概要

`LogWatcher`クラスはVRChatのログファイルを監視し、新しいログ行を検出するたびにイベントを発火するクラスです。ファイル監視の基本的な機能は実装されていますが、いくつかの問題点や改善点が見られます。

## 良い点

1. **非同期処理**: ログファイルの監視を非同期で行っており、メインスレッドをブロックしない設計になっています。
2. **キャンセルトークン**: 監視処理の停止に`CancellationTokenSource`を適切に使用しています。
3. **リソース管理**: `IDisposable`インターフェースを実装し、リソースの解放を行っています。
4. **柔軟性**: ログディレクトリとファイルフィルタを外部から指定できるようになっています。
5. **エラーハンドリング**: ログファイル処理中の例外をキャッチして、処理を継続できるようになっています。

## 問題点

1. **デフォルトイベントハンドラの実装**: `OnNewLogLine`イベントにデフォルトの空実装があります。これは不要であり、潜在的にnull参照の問題を隠してしまう可能性があります。
2. **ログの多さ**: `Console.WriteLine`が多用されており、通常運用時に大量のログが出力される可能性があります。
3. **ファイル変更検出の非効率性**: 定期的なポーリングでファイル変更を検出しており、`FileSystemWatcher`を使った方が効率的な場合があります。
4. **パスの検証不足**: ディレクトリパスや存在チェックが限定的で、無効なパスが指定された場合にエラーが発生する可能性があります。
5. **エンコーディングの固定**: ファイル読み込みのエンコーディングが`UTF-8`に固定されており、他のエンコーディングのログファイルに対応していません。
6. **イベント処理中の例外ハンドリング**: イベントハンドラ内で例外が発生した場合、キャッチしてログ出力するだけで特に対処していません。

## 改善案

1. **デフォルトイベントハンドラの削除**: イベント宣言を単純化し、null検証を追加します。

```csharp
/// <summary>
/// 新規ログ行を検出したときに発生するイベント
/// </summary>
public event Action<string, bool>? OnNewLogLine;

// イベント発火時にnull検証を行う
private void FireOnNewLogLine(string line, bool isFirstReading)
{
    OnNewLogLine?.Invoke(line, isFirstReading);
}
```

2. **ログレベルの導入**: ログ出力の詳細度を設定で制御できるようにします。

```csharp
private enum LogLevel
{
    Error,
    Warning,
    Info,
    Debug
}

private LogLevel _currentLogLevel = LogLevel.Info;

private void LogMessage(LogLevel level, string message)
{
    if (level <= _currentLogLevel)
    {
        Console.WriteLine($"[{level}] {message}");
    }
}
```

3. **`FileSystemWatcher`の使用**: ポーリングではなく、イベントベースのファイル監視を実装します。

```csharp
private FileSystemWatcher? _fileWatcher;

public void Start()
{
    Console.WriteLine($"LogWatcher.Start: {_lastReadFilePath}");

    // 監視対象の最新ログファイルが存在する場合は、最初に処理する
    if (!string.IsNullOrEmpty(_lastReadFilePath))
    {
        ReadNewLine(_lastReadFilePath);
    }

    // ファイルシステムウォッチャーの設定
    _fileWatcher = new FileSystemWatcher(_logDirectory)
    {
        Filter = _logFileFilter,
        NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.CreationTime,
        EnableRaisingEvents = true
    };

    _fileWatcher.Changed += OnFileChanged;
    _fileWatcher.Created += OnFileChanged;
}

private void OnFileChanged(object sender, FileSystemEventArgs e)
{
    // 最新のログファイルが対象のファイルと同じか確認
    var newestLogFile = GetNewestLogFile(_logDirectory, _logFileFilter);
    if (newestLogFile == e.FullPath)
    {
        ReadNewLine(e.FullPath);
    }
}
```

4. **パス検証の追加**: コンストラクタでパスの検証を行います。

```csharp
internal class LogWatcher : IDisposable
{
    /// <summary>
    /// コンストラクタ
    /// </summary>
    /// <param name="logDirectory">ログディレクトリのパス</param>
    /// <param name="logFileFilter">ログファイルのフィルタ</param>
    /// <exception cref="ArgumentException">ログディレクトリが存在しない場合</exception>
    public LogWatcher(string logDirectory, string logFileFilter)
    {
        if (!Directory.Exists(logDirectory))
        {
            throw new ArgumentException($"Log directory does not exist: {logDirectory}", nameof(logDirectory));
        }

        _logDirectory = logDirectory;
        _logFileFilter = logFileFilter;
        _lastReadFilePath = GetNewestLogFile(logDirectory, logFileFilter) ?? string.Empty;
    }

    // ...
}
```

5. **エンコーディング検出の改善**: ファイルのエンコーディングを自動検出するか、設定から指定できるようにします。

```csharp
private Encoding _fileEncoding = Encoding.UTF8;

public void SetEncoding(Encoding encoding)
{
    _fileEncoding = encoding ?? Encoding.UTF8;
}

private void ReadNewLine(string path)
{
    // ...
    using var reader = new StreamReader(stream, _fileEncoding, detectEncodingFromByteOrderMarks: true);
    // ...
}
```

6. **イベント処理のエラーハンドリング強化**: イベントハンドラのエラーを適切に処理します。

```csharp
private void FireOnNewLogLine(string line, bool isFirstReading)
{
    if (OnNewLogLine == null) return;

    var handlers = OnNewLogLine.GetInvocationList();
    foreach (var handler in handlers)
    {
        try
        {
            ((Action<string, bool>)handler)(line, isFirstReading);
        }
        catch (Exception ex)
        {
            LogMessage(LogLevel.Error, $"Error in event handler: {ex.Message}");
            // 必要に応じて例外をログファイルに記録したり、エラーイベントを発火したりする
        }
    }
}
```

## セキュリティの考慮事項

1. **ファイルアクセス権限**: ログディレクトリやファイルへのアクセス権限がない場合のエラーハンドリングを強化する必要があります。
2. **パスインジェクション**: ログディレクトリやファイルフィルタが外部から入力される場合、パス検証を強化する必要があります。

## パフォーマンスの考慮事項

1. **ポーリング間隔**: 現在は1秒間隔でポーリングしていますが、この間隔を設定可能にすることでリソース使用量を調整できます。
2. **大きなログファイルの処理**: 巨大なログファイルを一度に読み込むとメモリ使用量が増加する可能性があります。バッファリングを強化することを検討すべきです。
3. **FileSystemWatcherの利用**: ポーリングではなくイベントベースのファイル監視を使用することで、CPU使用率を低減できる可能性があります。

## 総評

`LogWatcher`クラスは基本的なログファイル監視機能を提供していますが、パフォーマンス、エラーハンドリング、柔軟性の面で改善の余地があります。特に、`FileSystemWatcher`の使用を検討し、エンコーディング処理とエラーハンドリングを強化することで、より堅牢で効率的なログ監視が可能になるでしょう。また、ログレベルの導入により、デバッグと通常運用時の出力を適切に制御できるようになります。

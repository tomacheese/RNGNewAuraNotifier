# AppConfig.cs レビュー結果

## ファイルの概要

`AppConfig.cs`はアプリケーションの設定を管理するクラスで、設定の読み込み・保存・アクセスのためのインターフェースを提供します。設定はJSON形式で保存され、VRChatのログディレクトリパスやDiscord WebhookのURLなどを管理しています。

## コードの良い点

1. 静的コンストラクタを使用して設定ファイルの初期ロードを行っている
2. JsonSerializerOptionsを適切に設定している（整形出力）
3. プロパティ値のバリデーションが実装されている
4. XMLドキュメントコメントが詳細

## 改善点

### 1. 設定アクセスの排他制御の不足

複数のスレッドから同時に設定にアクセスする場合に問題が発生する可能性があります。

**改善案**:

```csharp
internal class AppConfig
{
    // ...既存のコード...
    
    private static readonly object _lockObject = new();
    
    private static void Load()
    {
        lock (_lockObject)
        {
            if (!File.Exists(_configFilePath))
            {
                return;
            }

            var json = File.ReadAllText(_configFilePath);
            ConfigData config = JsonSerializer.Deserialize<ConfigData>(json) ?? throw new InvalidOperationException("Failed to deserialize config file.");
            _config = config;
        }
    }
    
    private static void Save()
    {
        lock (_lockObject)
        {
            var json = JsonSerializer.Serialize(_config, _jsonSerializerOptions);
            File.WriteAllText(_configFilePath, json);
        }
    }
    
    // ...プロパティも同様に排他制御...
}
```

### 2. 静的クラスの適用

クラス自体をインスタンス化せずに使用することが前提になっているため、静的クラスとして定義するべきです。

**改善案**:

```csharp
internal static class AppConfig
{
    // ...既存のコード...
}
```

### 3. 設定の変更イベント

設定が変更された際に通知するイベントメカニズムがありません。

**改善案**:

```csharp
internal static class AppConfig
{
    // ...既存のコード...
    
    /// <summary>
    /// 設定が変更されたときに発生するイベント
    /// </summary>
    public static event EventHandler<ConfigChangedEventArgs>? ConfigChanged;
    
    private static void OnConfigChanged(string propertyName)
    {
        ConfigChanged?.Invoke(null, new ConfigChangedEventArgs(propertyName));
    }
    
    // プロパティセッターでイベント発火
    public static string LogDir
    {
        // ...既存のゲッター...
        set
        {
            // ...既存のバリデーション...
            
            var oldValue = _config.LogDir;
            _config.LogDir = trimmedValue;
            Save();
            
            if (oldValue != trimmedValue)
            {
                OnConfigChanged(nameof(LogDir));
            }
        }
    }
}

public class ConfigChangedEventArgs : EventArgs
{
    public string PropertyName { get; }
    
    public ConfigChangedEventArgs(string propertyName)
    {
        PropertyName = propertyName;
    }
}
```

### 4. ファイルI/Oのエラーハンドリング

設定ファイルの読み書き時のエラーハンドリングが不足しています。

**改善案**:

```csharp
private static void Load()
{
    try
    {
        if (!File.Exists(_configFilePath))
        {
            return;
        }

        var json = File.ReadAllText(_configFilePath);
        ConfigData? config = JsonSerializer.Deserialize<ConfigData>(json);
        if (config != null)
        {
            _config = config;
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error loading config file: {ex.Message}");
        // デフォルト設定を使用
        _config = new ConfigData();
    }
}

private static void Save()
{
    try
    {
        var json = JsonSerializer.Serialize(_config, _jsonSerializerOptions);
        File.WriteAllText(_configFilePath, json);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error saving config file: {ex.Message}");
        // エラーを呼び出し元に通知する方法を検討
    }
}
```

### 5. PropertyChanged パターンの未適用

プロパティごとに個別の読み込みと保存が行われるため、複数の設定を変更する場合にパフォーマンス低下が発生します。

**改善案**:

```csharp
// 設定オブジェクト全体へのアクセスを提供
public static ConfigData GetConfig()
{
    Load();
    // 値のコピーを返して直接変更を防ぐ
    return new ConfigData
    {
        LogDir = _config.LogDir,
        DiscordWebhookUrl = _config.DiscordWebhookUrl
    };
}

// 一括で設定を保存
public static void UpdateConfig(ConfigData newConfig)
{
    // バリデーション
    if (!string.IsNullOrEmpty(newConfig.LogDir) && !Directory.Exists(newConfig.LogDir))
    {
        throw new DirectoryNotFoundException($"The specified directory does not exist: {newConfig.LogDir}");
    }
    
    if (!string.IsNullOrEmpty(newConfig.DiscordWebhookUrl) && 
        !newConfig.DiscordWebhookUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) && 
        !newConfig.DiscordWebhookUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
    {
        throw new ArgumentException("DiscordWebhookUrl must start with http or https.");
    }
    
    bool logDirChanged = _config.LogDir != newConfig.LogDir;
    bool webhookUrlChanged = _config.DiscordWebhookUrl != newConfig.DiscordWebhookUrl;
    
    _config = newConfig;
    Save();
    
    // 変更通知
    if (logDirChanged) OnConfigChanged(nameof(LogDir));
    if (webhookUrlChanged) OnConfigChanged(nameof(DiscordWebhookUrl));
}
```

## セキュリティの懸念点

1. 現在のファイルパスが`Environment.CurrentDirectory`に基づいており、アプリケーションの起動場所によって変わる可能性があります
2. Webhookの検証は単にプロトコルをチェックするだけで、実際の形式検証が行われていません

## パフォーマンスの懸念点

1. 各プロパティのget操作のたびに設定ファイルが読み込まれるため、パフォーマンスが低下する可能性があります
2. ネットワークドライブやアクセス権の問題で`Directory.Exists`が遅延する可能性があります

## 全体的な評価

AppConfigクラスは基本的な設定管理機能を提供していますが、マルチスレッド対応、エラー処理、パフォーマンス最適化などの点で改善の余地があります。特に設定アクセスの効率化とスレッドセーフ性の向上が重要です。また、設定変更イベントの実装により、設定変更をリアルタイムに反映できるようになるでしょう。

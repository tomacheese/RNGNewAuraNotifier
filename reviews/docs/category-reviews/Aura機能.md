# Aura機能 カテゴリのレビュー

このカテゴリには以下の 2 ファイルが含まれています：
## S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Aura\Aura.cs.md

`Aura`クラスはVRChatのElite's RNG Landで獲得できるオーラの情報を表現するレコードです。オーラのID、名前、レアリティ、ティア、サブテキストなどの属性を持ち、通知のためのテキスト生成メソッドも提供しています。全体的に適切に設計されていますが、いくつかの改善点があります。

### 良い点

1. **レコード型の採用**: C#のレコード型を使用して、値セマンティクスをもつ不変オブジェクトとして実装されています。
2. **詳細なコメント**: XMLドキュメントコメントが充実しており、プロパティやメソッドの役割が明確です。
3. **例外処理**: `GetAura`メソッドでデシリアライズ時の例外をキャッチし、フォールバック処理を行っています。
4. **適切な等価性比較**: `Equals`と`GetHashCode`を適切にオーバーライドして、IDベースの等価性比較を実装しています。
5. **フォーマットの一貫性**: レアリティの表示フォーマットなど、ユーザー向けの表示が一貫しています。

### 問題点

1. **静的メソッドの依存**: `GetAura`メソッドが`JsonData`クラスに静的に依存しており、テスト容易性と拡張性が低下しています。
2. **Null許容の不適切な使用**: `Name`プロパティがnull許容で、`GetNameText`メソッドでnullチェックが不十分です。
3. **バリデーション不足**: コンストラクタでパラメータのバリデーションが行われていません。
4. **Recordの機能不足**: Recordを使用していますが、`Equals`を手動でオーバーライドしています。
5. **GetNameTextの戻り値がnull許容**: `GetNameText`メソッドの戻り値が`string?`になっており、呼び出し側でnullチェックが必要です。
6. **ハードコードされたティア判定ロジック**: ティアの説明がコメントにハードコードされており、実際の判定ロジックがありません。

### 改善提案

1. **依存性注入の導入**: 静的依存を排除し、インターフェースを通じて依存関係を注入します。

```csharp
public interface IAuraRepository
{
    Aura? GetAuraById(int id);
    IEnumerable<Aura> GetAllAuras();
}

// 使用例
public static Aura GetAura(int auraId, IAuraRepository repository)
{
    try
    {
        return repository.GetAuraById(auraId) ?? new Aura(auraId);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error retrieving Aura({ex.GetType().Name}): {ex.Message}");
        return new Aura(auraId);
    }
}
```

2. **Null許容を削除**: 必須プロパティにはNull許容を使用せず、適切なデフォルト値を設定します。

```csharp
public string Name { get; init; } = string.Empty;

// GetNameTextも修正
public string GetNameText() => string.IsNullOrEmpty(SubText) ? Name : $"{Name} ({SubText})";
```

3. **バリデーションの追加**: コンストラクタでパラメータの検証を行います。

```csharp
public Aura(int id, string? name = null, int rarity = 0, int tier = 0, string subText = "")
{
    if (id <= 0)
        throw new ArgumentOutOfRangeException(nameof(id), "Aura ID must be positive");

    if (rarity < 0)
        throw new ArgumentOutOfRangeException(nameof(rarity), "Rarity cannot be negative");

    if (tier < 0 || tier > 5)
        throw new ArgumentOutOfRangeException(nameof(tier), "Tier must be between 0 and 5");

    Id = id;
    Name = name ?? string.Empty;
    Rarity = rarity;
    Tier = tier;
    SubText = subText ?? string.Empty;
}
```

4. **Recordの機能活用**: `Equals`と`GetHashCode`の手動実装を削除し、Recordの自動実装を活用します。

```csharp
// IDのみの等価性比較を行うレコード定義
internal record Aura(int Id)
{
    // 他のプロパティは通常のプロパティとして定義し、初期化のみ許可
    public string Name { get; init; } = string.Empty;
    public int Rarity { get; init; } = 0;
    public int Tier { get; init; } = 0;
    public string SubText { get; init; } = string.Empty;

    // 追加コンストラクタ
    public Aura(int id, string name, int rarity, int tier, string subText)
        : this(id) // プライマリコンストラクタを呼び出す
    {
        Name = name;
        Rarity = rarity;
        Tier = tier;
        SubText = subText;
    }

    // 他のメソッド...
}
```

5. **ティア判定ロジックの追加**: コメントに記載されているティア判定ロジックを実装します。

```csharp
/// <summary>
/// ラリティからティアを計算します
/// </summary>
/// <param name="rarity">ラリティ値</param>
/// <returns>対応するティア（0-5）</returns>
public static int CalculateTierFromRarity(int rarity)
{
    if (rarity == 0) return 0; // SPECIAL枠
    if (rarity < 1000) return 5;
    if (rarity < 10000) return 4;
    if (rarity < 100000) return 3;
    if (rarity < 1000000) return 2;
    return 1;
}
```

6. **ファクトリメソッドの改善**: より堅牢なファクトリメソッドを提供します。

```csharp
/// <summary>
/// ID指定でAuraを作成するファクトリメソッド
/// </summary>
/// <param name="id">AuraのID</param>
/// <returns>新しいAuraインスタンス</returns>
public static Aura CreateWithId(int id)
{
    // 既知のAuraを検索
    try
    {
        Aura[] auras = JsonData.GetAuras();
        return auras.FirstOrDefault(aura => aura.Id == id) ?? new Aura(id);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error creating Aura: {ex.Message}");
        // フォールバックとして基本情報のみのAuraを返す
        return new Aura(id);
    }
}
```

---

## S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Aura\NewAuraDetectionService.cs.md

`NewAuraDetectionService`クラスはVRChatのログを監視し、新しいAuraの取得を検出するサービスです。正規表現を使用してログパターンを検出し、Auraの取得イベントを発火する役割を担っています。

### 良い点

1. **単一責任の原則**: クラスは新しいAuraの検出に特化し、単一の責任を果たしています。
2. **正規表現の生成**: .NET 7以降で導入された`GeneratedRegex`属性を使用して効率的な正規表現の生成を行っています。
3. **依存性の注入**: コンストラクタで`LogWatcher`インスタンスを受け取り、依存性を注入しています。
4. **明確なコメント**: XMLドキュメントコメントが適切に記述されており、クラスとメソッドの役割が明確です。
5. **明示的な文化情報の指定**: `int.Parse`時に`CultureInfo.InvariantCulture`を使用して、ロケールに依存しない解析を行っています。

### 問題点

1. **デフォルトイベントハンドラの実装**: `OnDetected`イベントにデフォルトの空実装があります。これは不要であり、潜在的にnull参照の問題を隠してしまう可能性があります。
2. **リソース管理の欠如**: `IDisposable`インターフェースが実装されておらず、イベントハンドラの解除が行われていません。
3. **例外処理の不足**: `int.Parse`で例外が発生する可能性がありますが、それに対する処理がありません。
4. **ログ出力の過剰**: すべてのログ行に対して成功/失敗のログを出力しており、大量のログが生成される可能性があります。
5. **正規表現のメンテナンス性**: 正規表現が複雑で、将来的なログ形式の変更に対応しづらい可能性があります。
6. **単体テスト容易性の低さ**: `AuraLogRegex`が静的メソッドであり、モック化が難しいため、単体テストが困難です。

### 改善提案

1. **デフォルトイベントハンドラの削除**: イベント宣言を単純化し、null検証を追加します。

```csharp
/// <summary>
/// 取得された Aura を検出したときに発生するイベント
/// </summary>
/// <param name="aura">取得したAura</param>
/// <param name="isFirstReading">初回読み込みかどうか</param>
public event Action<Aura, bool>? OnDetected;

// イベント発火時にnull検証を行う
private void FireOnDetected(Aura aura, bool isFirstReading)
{
    OnDetected?.Invoke(aura, isFirstReading);
}
```

2. **リソース管理の改善**: `IDisposable`インターフェースを実装し、イベントハンドラの解除を行います。

```csharp
internal partial class NewAuraDetectionService : IDisposable
{
    // ...

    /// <summary>
    /// リソースを解放します
    /// </summary>
    public void Dispose()
    {
        if (_watcher != null)
        {
            _watcher.OnNewLogLine -= HandleLogLine;
        }
    }
}
```

3. **例外処理の追加**: `int.Parse`の例外をキャッチし、適切に処理します。

```csharp
private void HandleLogLine(string line, bool isFirstReading)
{
    Match matchAuraLogPattern = AuraLogRegex().Match(line);
    if (!matchAuraLogPattern.Success)
    {
        return;
    }

    try
    {
        var auraId = int.Parse(matchAuraLogPattern.Groups["AuraId"].Value, CultureInfo.InvariantCulture);
        OnDetected?.Invoke(Aura.GetAura(auraId), isFirstReading);
    }
    catch (FormatException ex)
    {
        Console.WriteLine($"Error parsing Aura ID: {ex.Message}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Unexpected error processing Aura log: {ex.Message}");
    }
}
```

4. **ログレベルの導入**: デバッグログの出力を設定で制御できるようにします。

```csharp
private bool _isDebugMode = false;

public void SetDebugMode(bool isDebug)
{
    _isDebugMode = isDebug;
}

private void LogDebug(string message)
{
    if (_isDebugMode)
    {
        Console.WriteLine($"[DEBUG] NewAuraDetectionService: {message}");
    }
}

private void HandleLogLine(string line, bool isFirstReading)
{
    Match matchAuraLogPattern = AuraLogRegex().Match(line);
    LogDebug($"matchAuraLogPattern.Success: {matchAuraLogPattern.Success}");
    // ...
}
```

5. **正規表現の構成要素分割**: 正規表現を構成要素に分割し、メンテナンス性を向上させます。

```csharp
// 日時部分の正規表現
private const string DateTimePattern = @"(?<datetime>[0-9]{4}\.[0-9]{2}.[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})";

// ログレベル部分の正規表現
private const string LogLevelPattern = @"(?<Level>.[A-z]+)";

// Aura取得メッセージ部分の正規表現
private const string AuraMessagePattern = @"\[<color=green>Elite's RNG Land</color>\] Successfully legitimized Aura #(?<AuraId>[0-9]+)\.";

// 完全なログパターンの正規表現
[GeneratedRegex(DateTimePattern + " " + LogLevelPattern + " *- *" + AuraMessagePattern)]
private static partial Regex AuraLogRegex();
```

6. **インターフェースの導入**: テスト容易性を向上させるためのインターフェースを導入します。

```csharp
/// <summary>
/// 新しいAuraログを検出するサービスのインターフェース
/// </summary>
public interface IAuraDetectionService
{
    /// <summary>
    /// 取得された Aura を検出したときに発生するイベント
    /// </summary>
    event Action<Aura, bool>? OnDetected;
}

/// <summary>
/// 新しいAuraログを検出するサービスの実装
/// </summary>
internal partial class NewAuraDetectionService : IAuraDetectionService, IDisposable
{
    // ...
}
```

---



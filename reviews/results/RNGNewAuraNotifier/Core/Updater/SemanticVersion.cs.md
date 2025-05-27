# SemanticVersion クラスのレビュー

## 概要

`SemanticVersion` クラスは、セマンティックバージョニングを表現し、バージョン番号の比較機能を提供するクラスです。このクラスは、RNGNewAuraNotifierプロジェクトとUpdaterプロジェクトの両方に同一の実装が存在しています。

## 良い点

1. **明確な責任**: セマンティックバージョンの表現と比較という明確な責任を持ったクラスになっています。
2. **適切なインターフェース実装**: `IComparable<SemanticVersion>` インターフェースを実装しており、順序付けが可能です。
3. **演算子のオーバーロード**: `>` と `<` 演算子がオーバーロードされており、直感的な比較が可能です。
4. **イミュータブル設計**: プロパティがget-onlyで、コンストラクタでのみ値が設定されるイミュータブルな設計になっています。
5. **適切なXMLドキュメント**: メソッドやプロパティに適切なXMLドキュメントコメントが付与されています。
6. **文化不変の数値解析**: `int.Parse`に`CultureInfo.InvariantCulture`を使用しており、文化に依存しない一貫した数値解析を行っています。

## 改善点

### 1. コード重複

同一のコードが2つのプロジェクトに存在しており、コード重複が発生しています。これは、将来的なメンテナンス性の問題を引き起こす可能性があります。

**改善案**:

- 共通ライブラリプロジェクトを作成し、両方のプロジェクトから参照する
- ソースファイルをリンクとして共有する（Linked Files機能を使用）

```xml
<!-- RNGNewAuraNotifier.csproj および RNGNewAuraNotifier.Updater.csproj に追加 -->
<ItemGroup>
  <Compile Include="..\Shared\SemanticVersion.cs">
    <Link>Core\Shared\SemanticVersion.cs</Link>
  </Compile>
</ItemGroup>
```

### 2. 完全なセマンティックバージョニング仕様への対応

現在の実装は、メジャー.マイナー.パッチの3つの要素のみをサポートしていますが、完全なセマンティックバージョニング仕様（SemVer 2.0）には、プレリリース識別子やビルドメタデータも含まれます。

**改善案**:

```csharp
internal class SemanticVersion : IComparable<SemanticVersion>
{
    public int Major { get; }
    public int Minor { get; }
    public int Patch { get; }
    public string[] PreRelease { get; } // プレリリース識別子（例: alpha.1, beta.2）
    public string[] BuildMetadata { get; } // ビルドメタデータ（例: build.123）

    public SemanticVersion(int major, int minor, int patch, string[]? preRelease = null, string[]? buildMetadata = null)
    {
        Major = major;
        Minor = minor;
        Patch = patch;
        PreRelease = preRelease ?? Array.Empty<string>();
        BuildMetadata = buildMetadata ?? Array.Empty<string>();
    }

    public static SemanticVersion Parse(string version)
    {
        // 基本バージョン部分とプレリリース/ビルドメタデータ部分を分離
        var versionParts = version.Split(new[] { '-', '+' }, 3);
        var mainVersion = versionParts[0];

        // メジャー.マイナー.パッチ部分を解析
        var parts = mainVersion.Split('.');
        if (parts.Length < 3)
        {
            throw new FormatException("Invalid semantic version");
        }

        int major = int.Parse(parts[0], CultureInfo.InvariantCulture);
        int minor = int.Parse(parts[1], CultureInfo.InvariantCulture);
        int patch = int.Parse(parts[2], CultureInfo.InvariantCulture);

        // プレリリース識別子を解析
        string[]? preRelease = null;
        string[]? buildMetadata = null;

        if (versionParts.Length > 1 && version.Contains('-'))
        {
            int preReleaseIndex = Array.IndexOf(versionParts, versionParts.FirstOrDefault(p => version.IndexOf('-' + p, StringComparison.Ordinal) > 0)) + 1;
            if (preReleaseIndex > 0 && preReleaseIndex < versionParts.Length)
            {
                preRelease = versionParts[preReleaseIndex].Split('.');
            }
        }

        // ビルドメタデータを解析
        if (versionParts.Length > 1 && version.Contains('+'))
        {
            int buildMetadataIndex = Array.IndexOf(versionParts, versionParts.FirstOrDefault(p => version.IndexOf('+' + p, StringComparison.Ordinal) > 0)) + 1;
            if (buildMetadataIndex > 0 && buildMetadataIndex < versionParts.Length)
            {
                buildMetadata = versionParts[buildMetadataIndex].Split('.');
            }
        }

        return new SemanticVersion(major, minor, patch, preRelease, buildMetadata);
    }

    // CompareTo、演算子オーバーロードなども完全なSemVer仕様に対応するように修正
}
```

### 3. 等価性の実装

現在のクラスは `IComparable<SemanticVersion>` を実装していますが、`IEquatable<SemanticVersion>` や `Equals`/`GetHashCode` のオーバーライドが行われていません。これにより、コレクション内での等価性比較やディクショナリキーとしての使用に問題が生じる可能性があります。

**改善案**:

```csharp
internal class SemanticVersion : IComparable<SemanticVersion>, IEquatable<SemanticVersion>
{
    // 既存のプロパティとメソッド

    public bool Equals(SemanticVersion? other)
    {
        if (other is null) return false;
        if (ReferenceEquals(this, other)) return true;

        return Major == other.Major && Minor == other.Minor && Patch == other.Patch;
    }

    public override bool Equals(object? obj)
    {
        if (obj is null) return false;
        if (ReferenceEquals(this, obj)) return true;
        if (obj.GetType() != GetType()) return false;

        return Equals((SemanticVersion)obj);
    }

    public override int GetHashCode()
    {
        return HashCode.Combine(Major, Minor, Patch);
    }

    public static bool operator ==(SemanticVersion? left, SemanticVersion? right)
    {
        if (left is null) return right is null;
        return left.Equals(right);
    }

    public static bool operator !=(SemanticVersion? left, SemanticVersion? right)
    {
        return !(left == right);
    }

    // その他の演算子（>=, <=）も追加
    public static bool operator >=(SemanticVersion a, SemanticVersion b)
        => a.CompareTo(b) >= 0;

    public static bool operator <=(SemanticVersion a, SemanticVersion b)
        => a.CompareTo(b) <= 0;
}
```

### 4. TryParseメソッドの追加

現在の`Parse`メソッドは例外をスローしますが、`TryParse`メソッドを追加することで、より柔軟な文字列解析オプションを提供できます。

**改善案**:

```csharp
public static bool TryParse(string s, out SemanticVersion? version)
{
    try
    {
        version = Parse(s);
        return true;
    }
    catch (Exception)
    {
        version = null;
        return false;
    }
}
```

### 5. 文字列形式の柔軟性向上

現在の`Parse`メソッドは、厳密に3つの数値部分が必要です。しかし、実際のセマンティックバージョニングでは、2つの数値部分（例：`1.0`）も有効な場合があります。より柔軟なパースロジックを実装することを検討すべきです。

**改善案**:

```csharp
public static SemanticVersion Parse(string s)
{
    var parts = s.Split('.');

    if (parts.Length < 1)
        throw new FormatException("Invalid semantic version");

    int major = int.Parse(parts[0], CultureInfo.InvariantCulture);
    int minor = parts.Length > 1 ? int.Parse(parts[1], CultureInfo.InvariantCulture) : 0;
    int patch = parts.Length > 2 ? int.Parse(parts[2], CultureInfo.InvariantCulture) : 0;

    return new SemanticVersion(major, minor, patch);
}
```

## セキュリティの考慮事項

`Parse`メソッドでは入力文字列の検証が最小限で、不正な入力に対して例外をスローする設計になっています。ユーザー入力や外部ソースから取得した文字列を直接パースする場合は、入力の検証を強化するか、`TryParse`メソッドを使用することが推奨されます。

## パフォーマンスの考慮事項

現在の実装は基本的に軽量であり、パフォーマンス上の大きな問題はありません。ただし、大量のバージョン比較を行う場合は、`CompareTo`メソッドの実装を最適化するとともに、一般的なケース（例：nullチェック）を高速に処理するパスを提供することを検討すべきです。

## 総評

`SemanticVersion`クラスは、基本的なセマンティックバージョニング機能を適切に実装しており、バージョン比較のニーズに対応しています。しかし、コード重複、完全なSemVer仕様への対応、等価性の実装、より柔軟な解析オプションの提供などの面で改善の余地があります。特に、同一コードが複数のプロジェクトに存在する問題は、将来的なメンテナンス性の観点から早急に対処すべき点です。

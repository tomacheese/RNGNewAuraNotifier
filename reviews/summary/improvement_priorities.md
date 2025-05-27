# RNGNewAuraNotifier プロジェクト 改善提案の優先度

## カテゴリ別優先度

| カテゴリ | 問題点数 | 改善提案数 | 優先度スコア |\n|---------|----------|------------|---------------|\n| GitHub設定 | 0 | 52 | 52 |\n| アプリケーション設定 | 0 | 37 | 37 |\n| 通知機能 | 11 | 10 | 32 |\n| Aura機能 | 12 | 7 | 31 |\n| その他 | 12 | 5 | 29 |\n| 構成管理 | 7 | 11 | 25 |\n| 更新機能 | 0 | 15 | 15 |\n| ユーザーインターフェース | 0 | 10 | 10 |\n| ドキュメント | 4 | 0 | 8 |\n| リソース | 0 | 8 | 8 |\n| Git設定 | 2 | 3 | 7 |\n| VS Code設定 | 0 | 3 | 3 |\n| ライセンス | 0 | 3 | 3 |\n| 依存関係管理 | 0 | 3 | 3 |\n| VRChat連携 | 0 | 0 | 0 |\n| アップデーター | 0 | 0 | 0 |\n| エディタ設定 | 0 | 0 | 0 |\n| JSON処理 | 0 | 0 | 0 |\n| コードスタイル | 0 | 0 | 0 |\n
## 高優先度の改善提案

### GitHub設定

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\review-config.yml.md**:

- 1. **レビュアー数の制限**: 割り当てるレビュアーの数を指定することで、すべてのレビュアーではなく一部のみを割り当てることができます。
- 2. **特定キーワードによるスキップ**: WIPやドラフトなど、特定のキーワードを含むプルリクエストに対してはレビュアーを割り当てないようにできます。
- 3. **ファイルパスに基づいたレビュアーの割り当て**: 変更されたファイルのパスに応じて、異なるレビュアーを割り当てることができます。
- 4. **レビュアーグループの使用**: 特定の部分に詳しいレビュアーのグループを定義できます。
- - LunaRabbit66
- - book000
- - LunaRabbit66
- - book000
- - wip
- - draft
- - [WIP]
- - LunaRabbit66
- - book000
- - LunaRabbit66
- - book000
- - ui-expert
- - ui-expert
- - core-expert
- - LunaRabbit66
- - book000
- - ui-reviewer1
- - backend-reviewer1

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\workflows\ci.yml.md**:

- 1. **テストの追加**: ユニットテストやインテグレーションテストを実行するステップを追加すると、コードの品質保証が向上します。
- 2. **キャッシュの活用**: 依存関係のキャッシュを活用して、ビルド時間を短縮できます。
- 3. **マトリックスビルド**: 複数の.NETバージョンやOSでのテストを追加することで、互換性を確保できます。
- 4. **依存関係の脆弱性スキャン**: セキュリティスキャンを追加して、依存関係の脆弱性を検出できます。
- 5. **コードカバレッジの追加**: テストのコードカバレッジを測定し、レポートを生成するステップを追加できます。
- - name: Run tests
- - name: Cache NuGet packages
- -
```
- - name: Run security scan
- - name: Generate code coverage
- - name: Upload coverage to Codecov

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\workflows\release.yml.md**:

- 1. **バージョン検証**: バージョン更新前後の検証ステップを追加することで、予期せぬエラーを防止できます。
- 2. **リリースノート改善**: 変更ログからより詳細なリリースノートを生成するステップを追加できます。
- - name: Verify version update
- - name: Generate detailed release notes

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\workflows\review.yml.md**:

- 1. **トリガーの拡張**: 追加のイベントタイプを含めることで、より多くのシナリオでレビュアーを割り当てることができます。
- 2. **レビュアー設定のカスタマイズ**: より詳細なレビュアー割り当てルールを設定することを検討できます。
- 3. **レビュー割り当て後の通知**: レビュー割り当て後にチャットツール（SlackやDiscord）などへの通知を追加することで、レビュープロセスを効率化できます。
- - LunaRabbit66
- - book000
- - wip
- - draft
- - LunaRabbit66
- - book000
- - ui-reviewer1
- - ui-reviewer2
- - ui-team
- - core-team
- - uses: kentaro-m/auto-assign-action@v2.0.0
- - name: Notify on Discord

### アプリケーション設定

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Properties\launchSettings.json.md**:

- 1. **複数プロファイルの追加**: 異なる起動設定を持つ複数のプロファイルを定義すると便利かもしれません。例えば：
- 2. **環境変数の追加**: 必要に応じて環境変数を定義することも検討してください。
- 3. **その他の設定オプション**: 必要に応じて追加の設定を検討できます：

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Properties\Resources.Designer.cs.md**:

- 1. **リソース使用方法の最適化**: リソースの使用に関するヘルパーメソッドを別のユーティリティクラスで提供することを検討できます。
- 2. **国際化対応**: 現状ではあまり活用されていませんが、`Culture` プロパティを使って多言語対応を実装することができます。

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Properties\Resources.resx.md**:

- 1. **リソースの整理**: 将来的にリソースが増えた場合、カテゴリ別にリソースファイルを分割することも検討できます。
- 2. **国際化対応**: 現在、アプリケーションは多言語対応していないようです。テキストリソースを追加し、国際化を検討できます。
- 3. **リソースの最適化**: バイナリデータ（Auras.json）は、実行時に効率的に処理できるよう、最適化を検討できます。
- - Resources.resx に言語リソースを追加 -->

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Properties\PublishProfiles\Publish.pubxml.md**:

- 1. **トリミングの検討**: アプリケーションサイズを小さくするために、`PublishTrimmed` を有効にすることを検討できます。ただし、リフレクションを使用する部分がある場合は注意が必要です。
- 2. **ReadyToRunの検討**: 起動時間を短縮するために、`PublishReadyToRun` を有効にすることを検討できます。
- 3. **圧縮の検討**: 配布サイズをさらに小さくするために、シングルファイル発行と圧縮を検討できます。
- 4. **発行設定の統一**: メインアプリケーションとアップデーターで設定を統一するために、共通のインポート設定を使用することを検討できます。
- 5. **バージョニング情報の追加**: 発行プロファイルにバージョン情報を含めることで、ビルドプロセスでの一貫性を確保できます。
- - ...existing properties... -->
- - ...existing properties... -->
- - ...existing properties... -->
- - Directory.Build.props -->
- - その他の共通設定 -->
- - 各プロジェクトの発行プロファイル -->
- - プロジェクト固有の設定 -->
- - ...existing properties... -->

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier.Updater\Properties\PublishProfiles\Publish.pubxml.md**:

- 1. **トリミングの検討**: アップデーターのサイズを小さくするために、`PublishTrimmed` を有効にすることを検討できます。特にアップデーターは機能が限定されているため、トリミングの恩恵を受けやすいでしょう。
- 2. **シングルファイル発行**: アップデーターを単一の実行ファイルとして配布するために、シングルファイル発行を検討できます。
- 3. **デバッグ情報の設定**: メインアプリケーションと同様に、デバッグ情報を埋め込む設定を追加することを検討できます。
- 4. **メインアプリケーションとの統一**: メインアプリケーションの発行プロファイルと設定を統一するために、共通のインポート設定を使用することを検討できます。
- 5. **説明的なコメント追加**: 設定の目的や意図を明確にするために、コメントを追加することを検討できます。
- - ...existing properties... -->
- - ...existing properties... -->
- - ...existing properties... -->
- - Directory.Build.props -->
- - その他の共通設定 -->
- - 各プロジェクトの発行プロファイル -->
- - プロジェクト固有の設定 -->
- - アップデーターの発行設定 - メインアプリケーションと統一される必要があります -->
- - リリース構成でビルド -->
- - ...他の設定とコメント... -->

### 通知機能

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Notification\DiscordNotificationService.cs.md**:

- 1. **エラー処理の追加**: Discord APIリクエスト時の例外をキャッチして適切に処理します。
- 2. **依存性注入の導入**: 設定を外部から注入できるようにします。
- 3. **色のカスタマイズ**: 通知の色をカスタマイズできるようにします。
- 4. **インターフェースの導入**: テスト容易性のためにインターフェースを導入します。
- 5. **Webhookクライアントの再利用**: シングルトンパターンでWebhookクライアントを再利用します。

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Notification\UwpNotificationService.cs.md**:

- 1. **エラー処理の追加**: 通知表示時のエラーをキャッチして適切に処理します。
- 2. **通知オプションの拡張**: より柔軟な通知設定を可能にします。
- 3. **通知IDの導入**: 通知を識別するためのIDを導入します。
- 4. **通知イベントの処理**: 通知のクリックなどのイベントを処理します。
- 5. **インターフェースの導入**: テスト容易性のためにインターフェースを導入します。

### Aura機能

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Aura\NewAuraDetectionService.cs.md**:

- 1. **デフォルトイベントハンドラの削除**: イベント宣言を単純化し、null検証を追加します。
- 2. **リソース管理の改善**: `IDisposable`インターフェースを実装し、イベントハンドラの解除を行います。
- 3. **例外処理の追加**: `int.Parse`の例外をキャッチし、適切に処理します。
- 4. **ログレベルの導入**: デバッグログの出力を設定で制御できるようにします。
- 5. **正規表現の構成要素分割**: 正規表現を構成要素に分割し、メンテナンス性を向上させます。
- 6. **インターフェースの導入**: テスト容易性を向上させるためのインターフェースを導入します。
- - *" + AuraMessagePattern)]

### その他

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\project.md**:

- 1. **依存性管理**: 多くのクラスでハードコードされた依存関係が存在し、テスト容易性と拡張性が低下しています。
- 2. **リソース管理**: `IDisposable`の実装が不十分であり、リソースリークの可能性があります。
- 3. **非同期プログラミング**: 非同期メソッドの使用に一貫性がなく、デッドロックの可能性があります。
- 4. **テスト不足**: 単体テストやインテグレーションテストが実装されていません。
- 5. **グローバルな状態**: 静的クラスや静的メソッドへの依存が多く、副作用の制御が困難です。

### 構成管理

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Config\AppConfig.cs.md**:

- 1. **インスタンスベースの設計**: 静的クラスではなく、インスタンスベースの設計に変更します。
- 2. **キャッシュの導入**: 設定の頻繁な読み込みを避けるためにキャッシュを導入します。
- 3. **例外処理の強化**: JSON読み込み時の例外処理を強化します。
- 4. **設定変更通知の追加**: 設定変更時にイベントを発火するメカニズムを追加します。
- 5. **URL検証の強化**: より堅牢なURL検証を導入します。
- - _lastLoadTime > _cacheTimeout)
- - _lastLoadTime > _cacheTimeout)

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Config\ConfigData.cs.md**:

- 1. **バリデーション機能**: プロパティに値が設定される際のバリデーションを追加することで、不正な値が設定されることを防げます。
- 2. **オプショナル設定**: 設定が存在しない場合のデフォルト値を指定する機能を追加できます。
- 3. **設定バージョン管理**: 将来的な設定形式の変更に備えて、バージョン番号を追加することを検討できます。
- 4. **コンストラクタの追加**: 設定オブジェクトを作成するための便利なコンストラクタを追加することができます。

### 更新機能

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Core\Updater\UpdateChecker.cs.md**:

- 1. **依存関係の注入**
- 2. **静的メソッドの多用**
- 3. **エラーハンドリングと報告**
- 4. **アプリケーション終了の処理**
- 5. **セキュリティ考慮事項**
- - コンストラクタで`GitHubReleaseService`を受け取っていますが、静的メソッド`CheckAsync`内で新しいインスタンスを作成しています
- - これにより、テスト時にモックオブジェクトを使用することが困難になっています
- - `CheckAsync`が静的メソッドとして実装されており、インスタンスメソッドと一貫性がありません
- - これにより、クラスの使用パターンが混在し、コードの理解と保守が困難になる可能性があります
- - エラーメッセージがコンソールに出力されていますが、システムトレイアプリケーションではユーザーに見えません
- - より適切なエラー報告メカニズム（例：イベント、ログファイル、通知）を実装すべきです
- - アップデーターを起動した後、`Application.Exit()`を呼び出していますが、これは適切にリソースを解放しない可能性があります
- - `Application.Exit()`の代わりに、正しくリソースを解放してから終了するメカニズムを検討すべきです
- - ダウンロードしたアップデートファイルの整合性や署名の検証が行われていません
- - これにより、悪意のあるアップデートが実行される可能性があります

### ユーザーインターフェース

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\UI\Settings\SettingsForm.Designer.cs.md**:

- 1. **アクセシビリティ向上**: コントロールにアクセシビリティのための追加情報を提供することを検討できます。
- 2. **レイアウト改善**: フォームのレイアウトをより洗練させるために、パネルやグループボックスを使用することを検討できます。
- 3. **入力検証**: 入力フィールドに基本的な検証を追加することを検討できます。
- 4. **ダークモード対応**: システムのダークモード設定に対応するよう、フォームのスタイルを調整することを検討できます。

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\UI\Settings\SettingsForm.resx.md**:

- 1. **リソースの最適化**: フォームに埋め込まれたアイコンなどのバイナリリソースのサイズを最適化することを検討できます。特に大きなアイコンや画像を使用している場合、適切なサイズに縮小することでアプリケーションの全体サイズを削減できます。
- 2. **共有リソースの活用**: 複数のフォームで同じアイコンやリソースを使用する場合、プロジェクト全体で共有するためにアプリケーションレベルのリソースファイル（`Properties/Resources.resx`）に移動することを検討できます。
- 3. **ローカライズ対応**: 将来的に多言語対応が必要になる場合に備えて、フォーム上のテキストをリソースファイルに分離することを検討できます。
- - Properties/Resources.resx に移動して共有 -->
- - アイコンデータ -->
- - 例: 文字列リソースの追加 -->

### ドキュメント

### リソース

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Resources\AppIcon.ico.md**:

- 1. **最新のデザインガイドラインへの対応**: 最新のWindows 11デザインガイドラインに沿ったアイコンデザインの更新を検討できます。
- 2. **多様なアイコンサイズの追加**: より多くのサイズバリエーション（特に高解像度ディスプレイ向けの大きなサイズ）を追加することで、様々な表示環境での見た目を向上させることができます。
- 3. **アプリケーションテーマとの一貫性**: アプリケーションのカラーテーマやブランディングと一貫性のあるデザインに更新することを検討できます。
- 4. **ダークモード対応**: ダークモード用の別バージョンのアイコンを用意することで、システムのテーマ設定に応じた最適な表示を実現できます。

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\RNGNewAuraNotifier\Resources\Auras.json.md**:

- 1. **スキーマバリデーション**: JSON スキーマを定義して、データの妥当性を検証する仕組みを追加すると良いでしょう。
- 2. **ドキュメント化**: 各フィールドの意味、特に `Rarity` と `Tier` の関係性についての説明を追加すると良いでしょう。
- 3. **カテゴリ分類**: Aura をカテゴリーやグループで分類することで、管理や表示が容易になる可能性があります。
- 4. **ローカライズ**: 将来の国際化に備えて、名前やサブテキストをローカライズ可能な構造にすることを検討しましょう。

### Git設定

**S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.gitignore.md**:

- 1. **環境設定ファイル**:
- 2. **デバッグ・プロファイリング**:
- 3. **パッケージ管理**:



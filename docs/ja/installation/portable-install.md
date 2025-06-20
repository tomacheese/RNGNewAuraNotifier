# インストール手順

このページでは、Elite's RNG Aura Observer を実行ファイルによるポータブルインストールする場合の手順について説明しています。

## 1. リリースページにアクセスしダウンロード

まず、[リリースページ](https://github.com/tomacheese/ElitesRNGAuraObserver/releases) にアクセスします。

アクセスすると以下のように、Assets という欄があります。
ここから `ElitesRNGAuraObserver.zip` を探し、クリックしてください。

![GitHub リリースページの画面](/docs/assets/installation/release-page.png)

## 2. ダウンロードしたファイルを展開し任意の場所に格納

ダウンロードしたファイルをダブルクリックして開くと、中に2つのファイルがあります。
設定によっては最後の `.exe` は表示されていないかもしれません。
これらのファイルをコピーし、お好きなところにペーストしてください。

ここでは、ユーザーフォルダに `ElitesRNGAuraObserver` というフォルダを作成し、その中にペーストしました。

![展開したファイルをフォルダーにコピーしている様子](/docs/assets/installation/copy-files.png)

## 3. アプリケーションを起動

さきほどペーストしたフォルダで、`ElitesRNGAuraObserver.exe` をダブルクリックして実行してください。

実行すると、以下のようにタスクトレイで常駐を開始します。
アプリケーションを終了したい場合は、右クリックし `Exit` をクリックしてください。

![Windows タスクトレイに常駐したアプリケーションアイコン](/docs/assets/installation/located-tasktray.png)

## 4. 設定画面で設定

アプリケーションを起動したら、初回の設定を行います。
タスクトレイでアプリケーションアイコンをダブルクリックするか、右クリックして `Settings` をクリックしてください。設定画面が開きます。

設定画面での設定項目については、[アプリケーションの設定](configuration.md) をご覧ください。

## 設定完了

ここまでの設定が完了すると、Windows 起動時にアプリケーションが自動的に起動し、[Elite's RNG Land](https://vrchat.com/home/world/wrld_50a4de63-927a-4d7e-b322-13d715176ef1) で Aura を獲得したときに、Windows トースト通知と Discord Webhook によって通知されます。

| Windows トースト通知 | Discord Webhook 通知 |
| :-: | :-: |
| ![Aura 獲得時の Windows トースト通知例](/docs/assets/installation/unlocked-new-aura-toast.png) | ![Aura 獲得時の Discord 通知例](/docs/assets/installation/unlocked-new-aura-discord.png) |

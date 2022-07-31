---
title: "プロジェクトセットアップ2：Prettier✏️"
free: false
---

# 参考資料
*"りあクト！ TypeScriptで始めるつらくないReact開発 第3.1版【Ⅱ. React基礎編】" - 第６章*
https://oukayuka.booth.pm/items/2368019
[対応レポジトリ>>>](https://github.com/oukayuka/Riakuto-StartingReact-ja3.1)

# Prettierを導入しよう！

## Prettierはなぜ必要なのか？

- コードフォーマット機能はeslintでも`--fix`などで使うことができる

が、

> 1. ルール設定がほとんど変更できず、コードスタイルの議論を生じさせない
> 2. 最大行長を考慮した修正を完全に自動で行え、手動修正が不要

という点で、Prettierを使うことで、さらにコードスタイルを簡単に統一することができる

## Prettierの環境を作る
https://github.com/mfunyu/pre-transcendence/commit/3afbe4a779ec583b446020c6bc9a827a00991414

### 1. インストール
```
npm install --save-dev prettier eslint-config-prettier
```

### 2. `.eslintrc.js`の編集

```diff js:.eslintrc.js
 module.exports = {
   ...
   extends: [
     ...
+     "prettier",
   ],
 };
```
:::message alert
他の競合する設定を上書きできるようにするため、必ず`extends`の最終行に追加する
:::

### 3. `.prettierrc`を作成

https://github.com/oukayuka/Riakuto-StartingReact-ja3.1/blob/master/06-lint/02-prettier/.prettierrc

### 4. 確認

- ルールに衝突がないか以下のコマンドで確認できる

```bash
npx eslint-config-prettier 'src/**/*.{js,jsx,ts,tsx}'     
```
- 以下のように表示されればOK
- そうでなければ、検出された設定を`.eslintrc.js`から削除する
```bash
$> npx eslint-config-prettier 'src/**/*.{js,jsx,ts,tsx}'
No rules that are unnecessary or conflict with Prettier were found.
```

### おまけ：VSCode設定
- `Prettier`の公式の拡張をインストールする
- 保存時に自動成形が走るように追記
```diff json:.vscode/settings.json
 {
 	 "editor.codeActionsOnSave": {
 		 "source.fixAll.eslint": true 
 	 },
 	 "editor.formatOnSave": false,
 	 "typescript.enablePromptUseWorkspaceTsdk": true,
+ 	"editor.defaultFormatter": "esbenp.prettier-vscode",
+ 	"[graphql]": {
+ 	  "editor.formatOnSave": true
+ 	},
+ 	"[javascript]": {
+ 	  "editor.formatOnSave": true
+ 	},
+ 	"[javascriptreact]": {
+ 	  "editor.formatOnSave": true
+ 	},
+ 	"[json]": {
+ 	  "editor.formatOnSave": true
+ 	},
+ 	"[typescript]": {
+ 	  "editor.formatOnSave": true
+ 	},
+ 	"[typescriptreact]": {
+ 	  "editor.formatOnSave": true
+ 	},
 }
```
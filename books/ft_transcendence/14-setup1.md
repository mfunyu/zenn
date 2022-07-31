---
title: "プロジェクトセットアップ1：Linter✏️"
free: false
---

# 参考資料
*"りあクト！ TypeScriptで始めるつらくないReact開発 第3.1版【Ⅱ. React基礎編】" - 第６章*
https://oukayuka.booth.pm/items/2368019
[対応レポジトリ>>>](https://github.com/oukayuka/Riakuto-StartingReact-ja3.1)

# ESlintを設定していこう！

Reactのコードを書いていくにあたって、linterと formatterを設定しておく

## まずlintって何？
- 「`lint`」＝ 各種言語で書かれたコードを解析して構文チェックを行うこと
- 「`linter`」＝ `lint`を行うプログラムのこと

:::message
Norminetteみたいなものですね！
:::

## ではESLintは？

- 開発者が独自のlintルールを設定できるlinter

> ◎ 拡張性
> ◎ 充実したドキュメント
> ◎ 読みやすく柔軟な記述ができる設定ファイル

他にもJavaScriptのためのJSLint、TypeScriptのためのTSLintなどが作られたが、ESLintが最も利用されておりかつ使用が推奨されている。


## ESLintの環境を作る
https://github.com/mfunyu/pre-transcendence/commit/b7a6ed02c4863b6275a94d533aa2fe9e2007976f

`create-react-app`を使用してReactプロジェクトを構築した場合には、ESLintパッケージがすでにインストールされている。
[Reactプロジェクトの作成手順振り返り>>>](https://zenn.dev/mfunyu/books/ft_transcendence/viewer/07-react2#%E3%83%97%E3%83%AD%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E4%BD%9C%E6%88%90)

- 以下のコマンドでESLintの設定ファイルを作成する

```
npm init @eslint/config
```
- 以下のような設定で作成した

![](https://storage.googleapis.com/zenn-user-upload/c13aa8d48efd-20220628.png)

::::details 作成された.eslintrc.jsファイル
```js:.eslintrc.js
module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'plugin:react/recommended',
    'airbnb',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: [
    'react',
    '@typescript-eslint',
  ],
  rules: {
  },
};
```
::::

### 0. ESLintを軽く理解する

| プロパティ名　| 内容 |
| -- | -- |
| `env` | 実行環境の指定　|
| `extends` | 共有設定の適用、後述が優先 |
| `parser` | ESLintの使用するパーサーの指定 |
| `parserOptions` | パーサーの実行オプションの指定 |
| `plugins` | 任意のプラグイン |
| `rules` | 適用する個々のルールと、エラーレベルや例外などの設定値を記述<br>(`extends`で適用されたルールを変更する) |

### 1. ESLintをカスタマイズする
https://github.com/mfunyu/pre-transcendence/commit/bd00fd02f74ac6a43c28f2c79b267e4a858d321e

とりあえず以下をコピーした。
https://github.com/oukayuka/Riakuto-StartingReact-ja3.1/blob/master/06-lint/01-eslint/.eslintrc.js

### 2. その他のファイル追加
https://github.com/mfunyu/pre-transcendence/commit/2bff55678e0fe9dcc474ed0d50d5dfba900781a3

- パーサーの走るファイルを指定して、不要なファイルに対して処理が行われないようにするため、`tsconfig.eslint.json`という別のファイルを作成する
```json:tsconfig.eslint.json
{
	"extends": "./tsconfig.json",
	"include": [
	  "src/**/*.js",
	  "src/**/*.jsx",
	  "src/**/*.ts",
	  "src/**/*.tsx",
	],
	"exclude": [
	  "node_modules"
	]
  }
```
- `.gitignore`のように`.eslintignore`ファイルを作成して、linterにかけたくないファイルを設定しておく
```.eslintignore
build/
public/
**/coverage/
**/node_modules/
**/*.min.js
*.config.js
*.*lint.js
```

- VSCode上の`.eslintrc.js`ファイルのエラーが消せなかったので、無効化コメントを追記した
```diff js:.eslintrc.js
+ /* eslint-disable */
 module.exports = {
 	env: {
```
### 3. `npm`のscriptを追加
https://github.com/mfunyu/pre-transcendence/commit/ada87d29f93cd8519d6cf00a93f9a575ede0c9fc

```bash
npm run lint
```

でESlintが全ファイルに対して走るようにする

```diff json:package.json
   "scripts": {
     "start": "react-scripts start",
     "build": "react-scripts build",
     "test": "react-scripts test",
     "eject": "react-scripts eject",
+    "lint": "eslint 'src/**/*.{js,jsx,ts,tsx}'",
+    "lint:fix": "eslint --fix 'src/**/*.{js,jsx,ts,tsx}'",
+    "preinstall": "typesync || :"
   },
```
### おまけ：VSCode設定
- `ESLint`の公式の拡張をインストールする
- 保存時にESlintが走るように設定する
```json:.vscode/settings.json
{
	"editor.codeActionsOnSave": {
		"source.fixAll.eslint": true 
	},
	"editor.formatOnSave": false,
	"typescript.enablePromptUseWorkspaceTsdk": true
}
```






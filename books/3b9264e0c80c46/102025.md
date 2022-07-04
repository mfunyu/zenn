---
title: "NestJSと知り合いになろう🤝"
free: false
---

# 参考資料
https://www.udemy.com/course/nestjs-t/

# NestJSって何？
- バックエンド開発フレームワーク
:::message
TypeScriptで作られている (=TypeScriptと相性がいい)
:::

## Why NestJS？
- TypeScriptのおかげで**型を使える**
	- チーム開発に適している
- **テストフレームワーク**が用意されている
	- 比較的簡単にテストができる

## Nest CLI？
**Nest CLI**を使用して開発するのが便利
煩わしいことを自動化してくれるコマンドラインインターフェース

例) 
```
nest new [project-name]
```
でプロジェクトディレクトリが作成できる！！
:::message
プロジェクト構成を自動生成してくれる 😳
:::

# ディレクトリ構成を理解する
ファイル数が多くて一見圧倒されてしまうプロジェクトディレクトリ。
ただ一度その構成を理解してしまえば、実際は至ってシンプルです（おそらく）
```
.
└── server/
    ├── README.md
    ├── nest-cli.json
    ├── node_modules/
    ├── package-lock.json
    ├── package.json
    ├── src/
    ├── test/
    ├── tsconfig.build.json
    └── tsconfig.json

4 directories, 6 files
```

| directory | what |
|---|---|
| **node_module** | プロジェクトが依存する**ライブラリ**が格納されているディレクトリ |
| **src** | **`main.ts`**： **最初に実行される**ファイル<br>・ その他重要なファイル（後述） <br>・ `spec`がついたファイルはテストファイル（`app.controller.spec.ts`) |
| **test** | **テスト**を格納するディレクトリ | 
| **その他** | ・ `package.json`: **NestJSを起動するコマンド**などが記載されている<br>・ `tsconfig.*`: TypeScriptの設定ファイル<br>・ 色々な設定ファイル | 

![in VSCode](https://storage.googleapis.com/zenn-user-upload/9ed38c128760-20220522.png =300x)
*VSCodeで見たディレクトリ構成*
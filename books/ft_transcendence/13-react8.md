---
title: "React Routerを知ろう！"
free: false
---

# 参考資料
*"りあクト！ TypeScript で始めるつらくない React 開発 第3.1版【Ⅲ. React 応用編】" - 第10章*
https://booth.pm/ja/items/2367992
[対応レポジトリ>>>](https://github.com/oukayuka/Riakuto-StartingReact-ja3.1)

## `<Link>`と`<a>`の違い

:::message alert
`<Link>`と`<a>`は異なる挙動をする
:::

- `<Link>`タグではReact Routerが遷移の処理を行う
- `<a>`タグを使うと、サーバーにHTTPリクエストが送信されるのでReact Routerの管轄外となる
- SPAのコード全体がリロードされることになるので、管理していた履歴が消えてしまう

- よってアプリケーション内では全て`<Link>`を使用するべきである

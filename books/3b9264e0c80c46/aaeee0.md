---
title: "Reactと知り合いになろう🤝"
free: false
---

# 参考資料
*"React - The Complete Guide (incl Hooks, React Router, Redux)" - Section1*
https://www.udemy.com/course/react-the-complete-guide-incl-redux/

# Reactって何？
- 本名は[**React.js**](https://reactjs.org/)

公式サイトによるとReactは
> A **JavaScript library** for building user interfaces

JavaScript ライブラリ。

ところで、JavaScriptってなんだっけ？という人は↓

::::details JavaScriptは何をしているのか？
- JavaScriptはブラウザで動くプログラミング言語

**以前は…**
リンクやボタンがクリックされたとき、毎度HTTPリクエストをサーバーに送ることで、違うHTMLページを表示させる ＝ 遅い

**JavaScriptなら…**
HTML構造（DOM）を操作することができる。
つまり、
ブラウザ上でのロードされたページの表示を書き換えることができる

リンクやボタンがクリックされたとき、**HTTPリクエストを送ることなく**、ユーザーに違う画面を提示することができる。

:::message
JavaScriptを使えば、違うHTMLを表示させるために、いちいちサーバーにリクエストを送る必要はない！！→ 高速化！
:::
::::

- "**reactive** interface"を作るためのJavaScriptライブラリ

- JavaScriptだけで、リアクティブインターフェースを作ることは可能。

だけど、
- めちゃくちゃ複雑なコードになる
- 何度も同じコードが必要になる
- 可読性、拡張性が低くなる

Reactは
- 低レベルのエレメントを作成したりCSSを設定したりする部分を担当し
- アプリケーションを役割ごとに小さいコンポーネントに分割することで
- より高度で複雑なUIの作成をより単純にしてくれる

:::message
Reactは、めんどくさいJavaScriptのコードを抽象化してくれている。
Reactを使うと、HTMLコードを書くかのように、わかりやすく、複雑なユーザーインターフェースを作成することができる
:::

# SPAs (Single-Page Applications) とは？

- 1つのHTMLのリクエストしか送信されないアプリケーションのこと

#### 例えば...
Reactを使ってページ全体をコントロールする場合、SPAを作ることができる
 
以前は
- Linkをクリックして新しいページに移遷する
	- **HTTPリクエストを投げ**て、新しいHTMLをサーバーから受け取る
	- ユーザーには違うページに移動したように見える

これがReactを使うと、
- Linkをクリックして新しいページに移遷する
	- React.jsを（通してJavaScriptを）使用
	- 画面に**表示するHTMLを変化**させる（HTMLをサーバーにリクエストしない）
	- ユーザーには違うページに移動したように見える


これにより
- スムーズなUI（ユーザーインターフェース）
- より良いUX（ユーザーエクスペリエンス）

が実現される！

例えば、Reactを使うSPAsにはNetflixなどがある。


:::message
最初のHTMLリクエストの後はReactがUIを変更するので、
2回以上HTMLをサーバーにリクエストすることがない！
:::

# React.jsの代替

- Angular
- Vue.js

https://academind.com/tutorials/angular-vs-react-vs-vue-my-thoughts



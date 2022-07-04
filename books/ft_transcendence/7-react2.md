---
title: "Reactアーキテクチャ理解💡"
free: false
---

# 参考資料
*"モダンJavaScriptの基礎から始める挫折しないためのReact入門" - Section6*
https://www.udemy.com/course/modern_javascipt_react_beginner/
*"React and Typescript: Build a Portfolio Project" - Section1*
https://www.udemy.com/course/react-and-typescript-build-a-portfolio-project/

# 大まかなファイル構成の理解

`public/`ディレクトリ配下に、`index.html`がある。

https://github.com/mfunyu/pre-transcendence/blob/main/pre-trans-app/public/index.html#L29-L42

これが、[シングルページアプリケーション](https://zenn.dev/mfunyu/books/3b9264e0c80c46/viewer/aaeee0#spas-(single-page-applications)-%E3%81%A8%E3%81%AF%EF%BC%9F)における、ブラウザからリクエストされる唯一のHTMLになる。
このHTMLページがリクエストされた後は、React（JavaScript）がHTMLを要素を書き換えて、画面の遷移を表現していく。

31行目にある
```html:public/index.html
<div id="root"></div>
```
が、HTMLのどの部分にJavaScriptをレンダリングしていくかという目印として設定されており、

これが`index.tsx`において

```ts:src/index.tsx
const root = ReactDOM.createRoot(
  document.getElementById("root") as HTMLElement
);
root.render(<App />);
```
- `getElementById`で`root`のIDを取得し、
- そのIDに対して`render`という処理でJavaScriptの内容を反映させている

という処理がなされることによって、レンダリングされている。

# ところで拡張子`.tsx`って何？

## JSX記法

```ts:App.tsx
function App() {
  return <div>Hello World!</div>;
}
```

 上のように、JavaScriptの中で、HTML要素をreturnする記法を**JSX記法**と呼ぶ

## `.ts` or `.tsx` ?

:::message
Reactを使うファイルは拡張子`.tsx`を使う
:::

| extention | when |
|---|---|
| `.tsx` | TypeScriptの中で、JSX記法を使うとき<br/>例）Reactを使いたいとき　|
| `.ts` | TypeScriptの中で、JSX記法を使わないとき|

# JSX記法の基本的なルール

:::message alert
returnするHTML要素は必ず全体をタグで囲む
:::
- returnの中身は全体が`<h1></h1>` `<div></div>`などのタグで囲まれている必要がある

- 1行の時はそのまま書ける
```ts::App.tsx
function App() {
  return <h1>Hello World!</h1>;
}
```

- 2行以上の時は`()`で囲む
```ts::App.tsx
function App() {
  return (
    <div>
      <h1>Hello World!</h1>
      <h2>Hello World!</h2>
    </div>
  );
}
```

- `<div>`を追加したくない時は`<React.Fragment>`で囲む
```ts::App.tsx
function App() {
  return (
    <React.Fragment>
      <h1>Hello World!</h1>
      <h2>Hello World!</h2>
    </React.Fragment>
  );
}
```

- `<React.Fragment>`を追加したくない時は`<>`で囲むことができる
```ts::App.tsx
function App() {
  return (
    <>
      <h1>Hello World!</h1>
      <h2>Hello World!</h2>
    </>
  );
}
```

:::message
結論: returnの中身は`()`で囲って、`<></>`タグで囲む
:::


# Reactのコンポーネント

コンポーネントとは：画面要素の1単位。1画面から1つのテキストボックスまでサイズは様々。

- HTMLの部分部分をファイルに分けて、コンポーネントとして管理する

- 現時点では`App.tsx`に書いてある`App`がコンポーネントの1つ

```ts:App.tsx
function App() {
  return (
    <>
      <h1>Hello World!</h1>
    </>
  );
}

export default App;
```

1. `App.tsx`で関数`App`を定義
2. `export default App;`と書くことで、外部から参照可能にする
3. `index.tsx`で`App`をインポート（`import App from "./App";`）
4. `root.render(<App />);`のように`App`がコンポーネントとしてHTMLタグのように使える

```ts:index.tsx
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";

const root = ReactDOM.createRoot(
  document.getElementById("root") as HTMLElement
);
root.render(<App />);
```

:::message alert
コンポーネント名は必ず先頭を**大文字から初める**(先頭が小文字だとエラー）
*PascalCase*を使用することが推奨されている
:::
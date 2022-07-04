---
title: "Reactとにかく書き始める: 実践編💻"
free: false
---

# 参考資料
*"モダンJavaScriptの基礎から始める挫折しないためのReact入門" - Section6*
https://www.udemy.com/course/modern_javascipt_react_beginner/
*"React and Typescript: Build a Portfolio Project" - Section2*
https://www.udemy.com/course/react-and-typescript-build-a-portfolio-project/


# 0. Hello World!
https://github.com/mfunyu/pre-transcendence/commit/3691219c1ec1bb00535c389498a394a7ed0591eb

`App.tsx`を書き換えてHello World!を表示させる

```diff ts:App.tsx
+import React from "react";
+
 function App() {
-  return <div></div>;
+  return (
+    <>
+      <h1>Hello World!</h1>
+    </>
+  );
 }
```

# 1. ボタンを追加する[^4518]

[^4518]: [モダンJavaScriptの基礎から始める挫折しないためのReact入門: Section6.44](https://mercari.udemy.com/course/modern_javascipt_react_beginner/learn/lecture/21899522#overview)

https://github.com/mfunyu/pre-transcendence/commit/d2c98563a96e32d6917a67649d743db0bc367e9a

### ボタン表示

- HTMLと同じようにボタンタグを追加することで、ボタンを表示させることができる。

```diff ts:App.tsx
function App() {
   return (
     <>
       <h1>Hello World!</h1>
+      <button>Clike here :)</button>
     </>
   );
 }
 ```
 
 ### ボタンクリック時のイベントを追加
 ![](https://storage.googleapis.com/zenn-user-upload/5f23c0bad553-20220614.png)

 
 - クリック時のイベントを追加するには、HTMLのイベントを使用する
[HTML onclick Event Attribute](https://www.w3schools.com/tags/ev_onclick.asp)
- HTMLでは`<element onclick="script">`というシンタックスが使われるが、Reactの中ではイベントが全て*camelCase*になるため、`<element onClick="script">`というシンタックスになる
  
 :::message
 Reactでは、HTMLの中で扱うタグ、イベントを*camelCase*で表す
 :::

- `onClick`で実行する関数を`onClickButton`で定義する。今回はアロー関数を使用
- まず簡単にアラートを表示させるようにする
 ```diff ts:App.tsx
 function App() {
+  const onClickButton = () => alert("Button clicked");
   return (
     <>
       <h1>Hello World!</h1>
+      <button onClick={onClickButton}>Click here :)</button>
     </>
   );
 }
 ```
 
 # 2.styleを追加する[^4518]
 
 ### タグ内に直接追記する
 https://github.com/mfunyu/pre-transcendence/commit/d379b4bab8f2c22fb9075634ab96bb501d6899bb
 
 - pタグを追加して、文章を表示させる
 - HTMLタグに`style`を追記することで、スタイルを追加することができる
 - `style={{ color: "#00babc" }}`のように要素を追加できる
 - `style={{内容}}`の外側の`{}`がJavaScriptを使用するという意味の`{}`
 - `style={{内容}}`の内側の`{}`はJavaScriptのオブジェクトとしての`{}`


 ```diff ts:App.tsx
function App() {
   return (
     <>
       <h1>Hello World!</h1>
+      <p style={{ color: "#00babc", fontSize: "20px" }}>42Tokyo : Japan</p>
       <button onClick={onClickButton}>Click here :)</button>
     </>
   );
 ```
 
 :::message
HTMLの中で扱うタグ、イベントは全て*camelCase*なので、`font-size`は`fontSize`で表す
 :::
 
 :::message　alert
JavaScriptのオブジェクトになるので、`"20px"`などは`""`で囲って文字列として表す必要がある
 :::
 
  ### 変数として定義する
  https://github.com/mfunyu/pre-transcendence/commit/5f45b33df859b9031589378dde7b387ba398b25d
  - JavaScriptのオブジェクトなので、直接書く代わりに、変数としても定義できる
  - これによりシンプルに見やすく書くことができる
  
   ```diff ts:App.tsx
    function App() {
   const onClickButton = () => alert("Button clicked");
+  const contentStyle = {
+    color: "#00babc",
+    fontSize: "20px",
+  };
   return (
     <>
       <h1>Hello World!</h1>
-      <p style={{ color: "#00babc", fontSize: "20px" }}>42Tokyo : Japan</p>
+      <p style={contentStyle}>42Tokyo : Japan</p>
       <button onClick={onClickButton}>Click here :)<
/button>
     </>
 ```

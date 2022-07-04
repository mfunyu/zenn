---
title: "Reactとにかく書き始める: 実践編3 State💻"
free: false
---

# 5. Stateを使ってみる

> **TODO：**
> Reactにおいて`Props`と並んで重要な概念である`State`について理解する

## Stateとは？
- 各コンポーネントが持つ状態。Stateが更新されることで、再レンダリングされる
- 条件によって動的に変わる部分をStateとして定義することで、さまざまな状態の画面を表示することができる
- `useState()`という関数を使う

## `useState()`を使う
https://github.com/mfunyu/pre-transcendence/commit/d7b848971584a9eabfb78ce8d7d40c8528b223f7

- `useState`は`react`からインポートする
- `useState()`の戻り値を変数名と関数名を指定して分割代入する
- 初期値を`useState`の引数に渡す。今回は`0`を渡す
- ここでは42の代わりに`num`を表示させるようにする

:::message
Stateを更新する関数名は`set+変数名`と設定することが多い
変数名を`item`とした場合は関数名が`setItem`になる
:::

```diff ts:App.tsx
-import React from "react";
+import React, { useState } from "react";
 import StyledMessage from "./components/StyledMessage";
 
 function App() {
   const onClickButton = () => alert("Button clicked");
+  const [num, setNum] = useState(0);
   return (
     <>
       <h1>Hello World!</h1>
-      <StyledMessage color="#00babc">42Tokyo : Japan</StyledMessage>
+      <StyledMessage color="#00babc">{num}Tokyo : Japan</StyledMessage>
       <button onClick={onClickButton}>Click here :)</button>
     </>
   );
  』
```

## ボタンによってStateを更新するように変更
https://github.com/mfunyu/pre-transcendence/commit/aeb21200b54d55a078e7376a21a8ccf0d7fc8aba
- Stateを更新したい場合は、その関数を呼び出すようにする
- ここでは、Step2で作成したボタンに`num`の更新を割り当てる
- `onClickButton`を`onClickCountUp`とリネームして、`setNum()`を関数内部で呼び出す
- 引数に更新したい値を入れるのでここでは`num + 1`を渡す

```diff ts:App.tsx
 ...
 function App() {
-  const onClickButton = () => alert("Button clicked");
+  const onClickCountUp = () => {
+    setNum(num + 1);
+  };
   const [num, setNum] = useState(0);
   return (
     <>
       <h1>Hello World!</h1>
       <StyledMessage color="#00babc">{num}Tokyo : Japan</StyledMessage>
-      <button onClick={onClickButton}>Click here :)</button>
+      <button onClick={onClickCountUp}>+1 :)</button>
     </>
   );
 }
```

:::message
`useState`を使って変数、更新関数と初期値を設定することで、コンポーネント内で要素を動的に変化させることができる
:::
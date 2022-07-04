---
title: "Reactとにかく書き始める: 実践編2 Props💻"
free: false
---

 
# 3. Propsを使ってみる[^6728]

[^6728]: [モダンJavaScriptの基礎から始める挫折しないためのReact入門: Section6.45](https://mercari.udemy.com/course/modern_javascipt_react_beginner/learn/lecture/21899530#overview)

> **TODO：**
> Step2で作ったMessageをコンポーネントとして切り出して、それを用いてPropsを使ってみる

## Propsとは

- **コンポーネントに対して渡す**引数のようなもの [コンポーネントってなんだっけ？>>>](https://github.com/mfunyu/pre-transcendence/commit/5f45b33df859b9031589378dde7b387ba398b25d)
- コンポーネントとして切り出した要素を、動的に使い回すための機能

## まずComponentを作る

- `components`ディレクトリを`src`配下に作成しておく

```shell
$> cd src     
$> mkdir components  
```

### 新しいコンポーネント用ファイルを作る
https://github.com/mfunyu/pre-transcendence/commit/34b554d2becc4bc71f9038ac82e60b9f1a8ff02d

- 適当な名前をつけてファイルを作り、先程追加したpタグに関連する部分を移植する
- ここでは`StyledMessage`とする

```ts:components/StyledMessage.tsx
function StyledMessage() {
  const contentStyle = {
    color: "#00babc",
    fontSize: "20px",
  };
  return (
    <>
      <p style={contentStyle}>42Tokyo : Japan</p>
    </>
  );
}

export default StyledMessage;
```
- 作ったファイルから`StyledMessage`をインポートする
- コンポーネントなので、`<StyledMessage />`のように書くことで使うことができる
- Step2と同じ画面が表示されていることを確認する

```diff ts:App.tsx
 import React from "react";
+import StyledMessage from "./components/StyledMessage";
 
 function App() {
   const onClickButton = () => alert("Button clicked");
-  const contentStyle = {
-    color: "#00babc",
-    fontSize: "20px",
-  };
   return (
     <>
       <h1>Hello World!</h1>
-      <p style={contentStyle}>42Tokyo : Japan</p>
+      <StyledMessage />
       <button onClick={onClickButton}>Click here :)</button>
     </>
   );
 ```
 
 ## Propsで条件を渡すようにする[^7018]
 https://github.com/mfunyu/pre-transcendence/commit/6932a99ffa68b228c68c8bf0779ef622a687e08f
 
 [^7018]: [React and Typescript: Build a Portfolio Project: Section2.7](https://mercari.udemy.com/course/react-and-typescript-build-a-portfolio-project/learn/lecture/24208886#overview)
 
 :::message
 型を指定する必要があるので、JavaScriptとTypeScriptでのpropsの扱いは異なる
 :::
 
 ### インターフェースを定義する
 
 - ここでは、色とメッセージを変更できるようにしたいので、以下のようなインターフェースを定義する
 - `components/StyledMessage.tsx`に追記

```ts:components/StyledMessage.tsx
interface MessageProps {
  color: string;
  message: string;
}
```

 ### インターフェースを型としてpropsを受け取る

- これを、`StyledMessage`で受け取る引数の引数の型として指定する

```ts:components/StyledMessage.tsx
function StyledMessage(props: MessageProps) {
```

- この状態では`App.tsx`の方でエラーが出るので、
```ts:App.tsx
      <StyledMessage color="#00babc" message="42Tokyo : Japan" />
```
のように`StyledMessage`コンポーネントのタグの中に指定する

:::message
propsを渡すときは、コンポーネントのタグの中に`渡したいprops名=要素`の形で渡すことができる
:::

```ts:components/StyledMessage.tsx
function StyledMessage(props: MessageProps) {
  console.log(props);
```
のように表示させると
![](https://storage.googleapis.com/zenn-user-upload/316dec75dae4-20220615.png)

とJavaScriptのオブジェクトが渡ってきていることが確認できる

 ### propsを使う
 :::message
 return内のHTML表記の中では、JavaScriptは`{}`で囲う必要がある
 :::

```diff ts:components/StyledMessage.tsx
+interface MessageProps {
+  color: string;
+  message: string;
+}
+
-function StyledMessage() {
+function StyledMessage(props: MessageProps) {
   const contentStyle = {
-    color: "#00babc",
+    color: props.color,
     fontSize: "20px",
   };
   return (
     <>
-      <p style={contentStyle}>42Tokyo : Japan</p>
+      <p style={contentStyle}>{props.message}</p>
     </>
   );
 }
```

# 4. Propsの`children`プロパティーを使ってみる
## `children`とは

- Reactのコンポーネントでは、`<App>ここの部分</App>`がpropsを受け取った時に`children`として自動的に受け取ることができる
```ts:色々省略してある例
function ComponentA (props) {
	return <p>{props.children}</p>; // <p>ContentsInside<p>となる
}

function Test() {
	return <ComponentA>ContentsInside</ComponentA>;
}
```
- ただし、TypeScriptでは、propsの型をinterfaceとして定義する必要があるので、`children`もそのままでは使えない

## `children`を使ってみる
https://github.com/mfunyu/pre-transcendence/commit/3b2c3695f8ce2b3362cda48c92da9f1290d89a46

参考[>>>](https://chaika.hatenablog.com/entry/2022/05/17/083000)

- 今まで`message=""`とコンポーネントのpropsに内容を指定していたが、これを他のHTMLと同じように`<></>`の間に要素を書くことで渡すようにする
- これにより、文字列だけでなくタグの間の要素全て（コンポーネントも含む）を`children`propとして渡すことができる
	```ts:example
	<Component1>
		<p>this is a sentence</p> 
		<Component2/>
	</Component1>
	```
	ここでは
	```ts
	<p>this is a sentence</p> 
	<Component2/>
	```
	が`children`と呼ばれるpropとして`Component1`に渡される
- これはReactの仕様



- まずは、`message`を削除して、代わりにタグの中に移動させる
```diff ts:App.tsx
function App() {
   ...
   return (
     <>
       <h1>Hello World!</h1>
-      <StyledMessage color="#00babc" message="42Tokyo : Japan" />
+      <StyledMessage color="#00babc">42Tokyo : Japan</StyledMessage>
       <button onClick={onClickButton}>Click here :)</button>
     </>
   );
```
- interfaceの中に`React.ReactNode`型の`children`を指定して、typescriptでもpropsとして受け取れるように指定する
```diff ts:StyledMessage.tsx
 interface MessageProps {
   color: string;
-  message: string;
+  children: React.ReactNode;
 }
 
 function StyledMessage(props: MessageProps) {
   ...
   return (
     <>
-      <p style={contentStyle}>{props.message}</p>
+      <p style={contentStyle}>{props.children}</p>
     </>
   );
 }
 ```

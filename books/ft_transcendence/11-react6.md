---
title: "Reactとにかく書き始める: 実践編4 useEffect💻"
free: false
---

# 6.　再レンダリングについて理解する

## 要素を条件付きで表示させる
https://github.com/mfunyu/pre-transcendence/commit/d3bb36e847d7b11c49cdc807495e147e5bfe32d5
- `useState`を使ってフラグをStateとして定義する
- フラグが`true`の時にのみ要素を表示させる
- 初期値を変更することで、要素の表示、非表示が切り替わる

```diff ts:App.tsx
   const [num, setNum] = useState(0);
+  const [showFaceFlag, setShowFaceFlag] = useState(true);
   return (
     <>
       <h1>Hello World!</h1>
       <StyledMessage color="#00babc">{num}Tokyo : Japan</StyledMessage>
       <button onClick={onClickCountUp}>+1 :)</button>
+      {showFaceFlag && <p> ^ ^</p>}
     </>
   );
 }
```

## [復習]　ボタンを追加して、表示・非表示を切り替える
https://github.com/mfunyu/pre-transcendence/commit/033cfaedb00b09b92bacb43ebd7295d4f6a23719
- `on / off`を切り替えるためのボタンを追加する
- `onClickSwitchFlag`という関数を作って、内部で`setShowFaceFlag`を使ってフラグを反転させる
- `onClick`に`onClickSwitchFlag`を設定する


```diff ts:App.tsx
 ...  
+  const onClickSwitchFlag = () => {
+    setShowFaceFlag(!showFaceFlag);
+  };
   const [num, setNum] = useState(0);
   const [showFaceFlag, setShowFaceFlag] = useState(true);
   return (
     <>
       ...
       <button onClick={onClickCountUp}>+1 :)</button>
+      <button onClick={onClickSwitchFlag}>on / off</button>
       {showFaceFlag && <p> ^ ^</p>}
     </>
    )
 ...  
```

## レンダリングを理解する

- 画面がレンダリングされた後に、Stateの更新が検知されれば、コンポーネントが上から再読み込みされて変更が適用される
- タブをリロードしなくても、ボタンをクリックした時などに画面の表示が変化しているのは、Reactのコンポーネントが**再レンダリング**されているからである

1. `console.log("begin");`を追記して、コンポーネントが読み込まれたときにログを出力させる
	```diff ts:App.tsx
	 function App() {
	+   console.log("begin");
	```
3. ブラウザでデベロッパーツールを開く
	> Internet Explorer では `F12` キーで開きます。
	> Mac OS X では `⌘ + ⌥ + I` キーで開きます。
4. ボタンのクリック数だけbeginのログが増えていくことを確認
	![](https://storage.googleapis.com/zenn-user-upload/8b7963065fb5-20220627.png)
	
### 再レンダリングされる条件

- Stateが変更された時
- Propsを受け取っている場合にその中身が変化した場合
- 親のコンポーネントが再レンダリングされた場合
	```diff ts:StyledMessage.tsx
	 function StyledMessage(props: MessageProps) {
	+    console.log("child");
	```
	- ボタンをクリック（Stateを変更）すると`App`の子コンポーネントに当たる`StyledMessage`も再レンダリングされていることがわかる
	![](https://storage.googleapis.com/zenn-user-upload/993c8a577f41-20220627.png)


:::message
Reactは変更があったときに、コンポーネントを再レンダリングして差分を反映させている
:::

## 再レンダリングの落とし穴
https://github.com/mfunyu/pre-transcendence/commit/7b1b444273aaa5a544d5ed912140daf3d8c70712

- 以下のような条件を追加すると、エラーが起きるようになる
- これは再レンダリングの際に再度条件文に入ってしまい、set関数が呼び出されることで、レンダリング無限ループが生じてしまうことによる

```diff ts:App.tsx
+  if (num % 3 === 0) {
+    setShowFaceFlag(true);
+  else {
+    setShowFaceFlag(false);
+  }
```
![](https://storage.googleapis.com/zenn-user-upload/b967bdb18708-20220627.png)

- これを修正するには、フラグの状態が異なる時にのみset関数が呼び出されるように書き換える

https://github.com/mfunyu/pre-transcendence/commit/a660fa251b04d4e1630379609bf294b26b8df9d7
```diff ts:App.tsx
  if (num % 3 === 0) {
+    showFaceFlag || setShowFaceFlag(true);
  } else {
+    showFaceFlag && setShowFaceFlag(false);
  }
```

:::message
set関数が呼ばれる条件を制限することで無限レンダリングを防ぐ
:::

- ここで、CountUpのボタンを使うと`^ ^`が3の倍数の時に表示されるようになった
- が、on/offのボタンが動作しなくなっている
- これを次のStepで修正していこう！

:::message alert
on/offのボタンから`onClickSwitchFlag`が呼ばれてフラグが変更されると、再レンダリングが走る。
その時に、変更されていない`num`の値によって`setShowFaceFlag`が呼ばれてフラグが再度更新されてしまうので、on/offによるフラグの設定を反映できなくなっている
:::

# 7.　useEffectを使ってみよう！

> **TODO:**
> `useEffect`を使ってStateの関心を分離する

- 扱うStateが多くなると、互いの処理が干渉して期待通りに動かなくなることがある
- `useEffect`を使うことで関心を分離し、特定のStateの変更において特定の処理を実行するように指定することができる

## `useEffect`の使い方を知る

0. `useEffect`の第一引数は関数を取るので、ログを出力するアロー関数を渡す

```ts:App.tsx
  useEffect(() => {
    console.log("useEffect");
  });
```
- これだけでは、再レンダリングされる際に毎回呼び出されていることが確認できる

![](https://storage.googleapis.com/zenn-user-upload/618b58ca9b14-20220627.png)

a. `useEffect`の第二引数に空の配列を渡す
```ts:App.tsx
  useEffect(() => {
    console.log("useEffect");
  }, []);
```

- 空の配列を渡すと、最初にレンダリングされた時にのみ関数が呼び出される
![](https://storage.googleapis.com/zenn-user-upload/eb328fc10503-20220627.png)

:::message
最初の一回だけ呼び出したいような処理に使用する
:::

b. 変数の配列を渡す
```ts:App.tsx
  useEffect(() => {
    console.log("useEffect");
  }, [num]);
```
- 渡した変数に変更があった時にのみ関数が呼び出されるようになる
- 1回目にCountUp、2回目にon/offのボタンを押している
![](https://storage.googleapis.com/zenn-user-upload/2f1570aaae1a-20220627.png)

## 
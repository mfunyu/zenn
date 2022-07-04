---
title: "Reactとにかく書き始める: 準備編💻"
free: false
---

# 参考資料
*"React - The Complete Guide (incl Hooks, React Router, Redux)" - Section29*
https://www.udemy.com/course/react-the-complete-guide-incl-redux/
*"React and Typescript: Build a Portfolio Project" - Section1*
https://www.udemy.com/course/react-and-typescript-build-a-portfolio-project/

# プロジェクト作成

- nodeをインストールする

https://nodejs.org/
```shell
node --version
```

### プロジェクト作成

- `npx create-react-app 新ディレクトリ名`をプロジェクトルートで実行する

が、ここではJavaScriptではなくTypeScriptで進めたいので
`npx create-react-app 新ディレクトリ名 --template typescript`でプロジェクトを作成する必要がある

:::message alert
typescriptでのプロジェクトを作るために、`--template typescript`の指定を忘れない!
:::
```shell
$> npx create-react-app my-react-app　--template typescript
Need to install the following packages:
  create-react-app
Ok to proceed? (y) y
```
インストールが終わるとディレクトリ構成が以下のようになる
```shell
$> tree
.
└── my-react-app
　   ├── README.md
　   ├── node_modules
　   ├── package-lock.json
　   ├── package.json
　   ├── public
　   ├── src
　   └── tsconfig.json
```
https://github.com/mfunyu/pre-transcendence/commit/ed18379654a3b8eb83e7c269237b6833b556697f

## もう動かせる!
![デフォルト表示](https://storage.googleapis.com/zenn-user-upload/30b9f999c9ae-20220613.png)

```shell
$> cd my-react-app
$> npm start
```
- `npm start`でプロジェクトをスタート
- http://localhost:3000/ が新規タブで自動的に開かれる
- デフォルトの上のようなReactページが表示される

## いらないファイルを消そう
https://github.com/mfunyu/pre-transcendence/commit/4bafcc6e5f4ca737145d2ca3efeb66be6a895036

`src/`ディレクトリ下の以下のファイルを削除
- `App.css`
- `App.test.tsx`: 自動テストのためのファイル
- `logo.svg`
- `react-app-env.d.ts`
- `reportWebVitals.ts`
- `setupTests.ts`

上記以外のファイルも必要に応じて削除して、`src/`ディレクトリには以下のファイルだけが残る状態にする
- `App.tsx`
- `index.css`
- `index.tsx`

### 残ったファイルを修正する
いらないファイルの削除に応じて、残った3つのファイルについても不要な記載を削除する

`index.css`は中身を空にする
```diff css:index.css
```

```diff ts:App.tsx
-import React from 'react';
-import logo from './logo.svg';
-import './App.css';
-
 function App() {
-  return (
-    <div className="App">
-      <header className="App-header">
-        <img src={logo} className="App-logo" alt="logo" />
-        <p>
-          Edit <code>src/App.tsx</code> and save to reload.
-        </p>
-        <a
-          className="App-link"
-          href="https://reactjs.org"
-          target="_blank"
-          rel="noopener noreferrer"
-        >
-          Learn React
-        </a>
-      </header>
-    </div>
-  );
+  return <div></div>;
 }
 
 export default App;
```

```diff ts:index.tsx
-import React from 'react';
 import ReactDOM from 'react-dom/client';
 import './index.css';
 import App from './App';
-import reportWebVitals from './reportWebVitals';

 const root = ReactDOM.createRoot(
   document.getElementById('root') as HTMLElement
 );
 root.render(
-  <React.StrictMode>
     <App />
-  </React.StrictMode>
 );
-
-// If you want to start measuring performance in your app, pass a function
-// to log results (for example: reportWebVitals(console.log))
-// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
-reportWebVitals();
```
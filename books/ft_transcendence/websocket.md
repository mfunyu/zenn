---
title: "websocket"
free: false
---

# 参考資料
https://docs.nestjs.com/websockets/gateways


# WebSocket実装準備

## frontend - パッケージインストール

```shell
npm install @types/socket.io-client
```
:::message
`npm install` でも `npm i` でも同じ
:::

## backend
### パッケージインストール
```shell
npm i --save @nestjs/websockets @nestjs/platform-socket.io
npm i --save-dev @types/socket.io
```

- エラーが出たので以下のように[legacy-peer-deps](https://docs.npmjs.com/cli/v7/using-npm/config#legacy-peer-deps)をtrueに設定して再度`@nestjs/websockets`をインストールした
```shell
npm config set legacy-peer-deps true
```
### モジュールの作成
- モジュールを追加
```shell
nest g module chat 
```
- `gateway`追加
```shell
nest g gateway chat --no-spec
```

### `chat.gateway.ts`を編集[^214]
[^214]: [[WebSocket] NestJSとReactでWebSocket通信してみた](https://qiita.com/jumokuzai/items/39f9bc0213e00e2a4de8)

:::message alert
フロントとバックエンドでポートが違うため違うURLにアクセスすることになる。
よってCORS（Cross-origin resource sharing）を設定しなければならない。
詳しくは[CORS | NestJS >>>](https://docs.nestjs.com/security/cors)を参照
:::

```diff ts:chat.gateway.ts
 import { SubscribeMessage, WebSocketGateway } from '@nestjs/websockets';
 
-@WebSocketGateway()
+@WebSocketGateway({ cors: { origin: '*' } })
 export class ChatGateway {
```
https://github.com/mfunyu/pre-transcendence/commit/3c019b5003db82e58c042b994feaab60e01d2507


# WebSocket実装
:::message
ブロックの最後に`App.tsx`のコード全体を記載している
:::
## frontend フィールドの追加
https://github.com/mfunyu/pre-transcendence/commit/47103c187c0967f5d72e7b7b8100d5adc67e7001

- まず、websocketのトリガー用としてUIにインプットフィールドとボタンを追加
```diff ts:App.tsx
       </button>
       {showFaceFlag && <p> ^ ^</p>}
-      <input id="inputText" type="text" />
-      <input id="sendButton" type="submit" />
     </>
   );
 };
```

## socketを作成
- `socket.io-client`から`io`をインポート
- `io(url)`でsocketインスタンスを作成する
- `onClick`のイベントに関数を設定する

```diff ts:App.tsx
-import React, { useState, useEffect } from 'react';
+import React, { useState, useEffect, useCallback } from 'react';
+import io from 'socket.io-client';
 import StyledMessage from './components/StyledMessage';
 
 const App = () => {
   const [num, setNum] = useState(0);
   const [showFaceFlag, setShowFaceFlag] = useState(true);
 
+  const socket = io('http://localhost:3000');
+
	
	...
 
+  const onClickSubmit = useCallback(() => {
+    socket.emit('message', 'hello');
+  }, []);
+
   return (
     <>
	  ...
       </button>
       {showFaceFlag && <p> ^ ^</p>}
       <input id="inputText" type="text" />
-      <input id="sendButton" type="submit" />
+      <input id="sendButton" onClick={onClickSubmit} type="submit" />
     </>
   );
```

完成！

https://github.com/mfunyu/pre-transcendence/blob/eb8ec33ab6c586943c1cb8a748f9991864039903/pre-trans-app/src/App.tsx

といっても、これでは動いているのかの確認ができないので、ログを追加して確認していく↓

## ログを追記

### frontend 
https://github.com/mfunyu/pre-transcendence/commit/3b612619a4df40e00d98462f7fa979a1a7916d80
- 最初にレンダリングされる時にsocketIDをログに出力する
![](/images/websocket/2022-08-09-23-50-03.png)
```diff ts:App.tsx
   ...
   }, [num]);
 
+  useEffect(() => {
+    socket.on('connect', () => {
+      // eslint-disable-next-line no-console
+      console.log('connection ID : ', socket.id);
+    });
+  }, []);
+
   const onClickSubmit = useCallback(() => {
     socket.emit('message', 'hello');
   }, []);
```

### backend
https://github.com/mfunyu/pre-transcendence/commit/de91e96ebdb4f7adf32f9f7ba2241deae69c8a7d

- Loggerを追加して、`message`を受信したときにターミナルにログを出力させる
![](/images/websocket/2022-08-10-00-36-50.png)

```diff ts:chat.gateway.ts
 import { SubscribeMessage, WebSocketGateway } from '@nestjs/websockets';
+import { Logger } from '@nestjs/common';
 
 @WebSocketGateway({ cors: { origin: '*' } })
 export class ChatGateway {
+  private logger: Logger = new Logger('Gateway Log');
+
   @SubscribeMessage('message')
   handleMessage(client: any, payload: any): string {
+    this.logger.log('message recieved');
     return 'Hello world!';
   }
 }
```

これでフロントエンドとバックエンドの両方で、ソケット通信に際してログが出力されるようになった

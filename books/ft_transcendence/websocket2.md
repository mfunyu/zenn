---
title: "WebSocket実装: Server to Client 📥"
free: false
---

# 2. WebSocket実装編 [Server → all Clients]

> **TODO：**
> Server(`backend`)から全てのClientに、一斉にメッセージを送信できるようにする

## a. [back] メッセージをClientに送り返す

https://github.com/mfunyu/pre-transcendence/commit/a0f2d66becd23ec97ce3c2489372b7c1108bce7e

- Serverインスタンス[(Nest公式ドキュメント)](https://docs.nestjs.com/websockets/gateways#server)を追加して、メッセージを送り返すようにする
- ここではevent名を`'update'`と設定したが、ここは自由に設定する

```diff ts:chat.gateway.ts
 import {
   SubscribeMessage,
   WebSocketGateway,
+  WebSocketServer,
   MessageBody,
 } from '@nestjs/websockets';
 import { Logger } from '@nestjs/common';
+import { Server } from 'socket.io';
 
 @WebSocketGateway({ cors: { origin: '*' } })
 export class ChatGateway {
+  @WebSocketServer()
+  server: Server;
+
   private logger: Logger = new Logger('Gateway Log');
 
   @SubscribeMessage('message')
-  handleMessage(@MessageBody() message: string): string {
-    this.logger.log(message);
-    return 'Hello world!';
+  handleMessage(@MessageBody() message: string) {
+    this.logger.log('message recieved');
+    this.server.emit('update', message);
   }
 }
```

## b. [front] Serverからのメッセージを表示する

### Serverからの通信を受け取る

- `socket.on()`でServerからのレスポンスをリッスンする
- 先ほどServer側でemitするeventを`'update'`と名付けたので、ここでも`'update'`を指定する
- レスポンスを受け取ったら、consoleにログを出力する
```diff ts:App.tsx
   ...
+  socket.on('update', (message: string) => {
+    console.log('recieved : ', message);
+  });
+
  return (
     <>
       <h1>Hello World!</h1>
  ...
```
:::message
確認のためなので、上記の変更はコミットしていない
:::

### Serverから受け取ったメッセージを表示する
https://github.com/mfunyu/pre-transcendence/commit/b393276fa1ed2e870a1c8354a2f81791bb8c6dc3

![](/images/websocket2/2022-08-14-00-06-00.png)

- 前項での変更の代わりに以下を追記する
- `chatLog`を追加して、メッセージを受信するごとにアップデートする
- `chatLog`の中身をループで表示させる
:::message alert
[修正点]
Consoleを見ると、Logが増えるとともにレンダリングの回数が増えていることがわかる。
下記コードでは修正済みだが上記のcommit時には修正されていないので要注意。
`useEffect`の第二引数を`[chatLog]`から`[]`(空配列)に修正した。
:::

```diff ts:App.tsx 
   ...
   const [inputText, setInputText] = useState('');
+  const [chatLog, setChatLog] = useState<string[]>([]);
 
   ...
+  useEffect(() => {
+    socket.on('update', (message: string) => {
+      console.log('recieved : ', message);
+      setChatLog([...chatLog, message]);
+    });
+  }, []);
+
   return (
     <>
       ...
       <input id="sendButton" onClick={onClickSubmit} type="submit" />
+      {chatLog.map((message, index) => (
+        <p key={index}>{message}</p>
+      ))}
     </>
   );
 };
```

## c. 2画面で確認する

![](/images/websocket2/2022-08-14-00-16-58.png)

わかりにくいが、、、
- 左のウィンドウ、右のウィンドウの順にメッセージを入力
- リロードしなくてもどちらのメッセージも表示される

:::message
これで、コネクションが確立している全てのClientに同時にメッセージを返すことができるようになった👏👏
:::
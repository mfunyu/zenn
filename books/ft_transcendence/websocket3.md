---
title: "WebSocket実装: Server to Client 2 📤"
free: false
---

# 参考資料
https://socket.io/docs/v3/rooms/
https://atmarkit.itmedia.co.jp/ait/articles/1607/01/news027.html

# 3. room: 任意の範囲内で通信 [Server → some Clients]

> **TODO：**
> socket.ioの`room`機能を使って、Server(`backend`)から特定のClientに、メッセージを一括送信できるようにする
> → 簡易的なチャットルームの実装

## a. [front] ルームを選択可能にする
https://github.com/mfunyu/pre-transcendence/commit/83d28fb7b225dafaa0cbec524770dfe781e23911

![](/images/websocket3/2022-08-16-22-46-33.png)

- selectを追加して、ルームを選べるようにする
- ルームの更新を`roomID`stateで管理する
- ルーム変更時に、`'joinRoom'`イベントをemitし、ついでに`chatLog`を空にする

:::message
チャットログは保存していないので、入室時以前のチャット内容は見ることができない
:::

```diff ts:App.tsx
   const [msg, setMsg] = useState('');
+  const [roomID, setRoomID] = useState('');
   ...

+      <select
+        onChange={(event) => {
+          setRoomID(event.target.value);
+          socket.emit('joinRoom', event.target.value);
+          setChatLog([]);
+        }}
+        value={roomID}
+      >
+        <option value="">---</option>
+        <option value="room1">Room1</option>
+        <option value="room2">Room2</option>
+      </select>
       <input
         id="inputText"
         type="text"
       ...
```

## b. [back] ルームの作成、入室中のルームにメッセージを送信する

https://github.com/mfunyu/pre-transcendence/commit/be235c6554a31a0db28b31a80649ce977446c65a

#### `'joinRoom'`のメッセージハンドラを作成する
- `@SubscribeMessage('joinRoom')`のデコレーターを持つ関数を追加し、MessageBodyにroomIDを受け取る
- `@ConnectedSocket() socket: Socket`も引数に持たせ、接続しているソケットの情報を受け取れるようにする
- `socket.join(roomId);`で`roomId`という名前のルームに対象のソケットを参加する

#### 1つのソケットは最大1つのチャットルームに入るようにする
- よってそれを実現するために、`'joinRoom'`時にすでに入室中のチャットルームがあれば、`socket.leave(room)`で退室させる
- `socket.rooms`で現在そのソケットが属しているルームを取得
  -  `socket.rooms`に関する説明 → [Socket.io公式 >>>](https://socket.io/docs/v3/rooms/#disconnection)
- 2つ目の要素が取得したい参加しているroomだが、`socket.rooms`はarrayではなくSetなので工夫してとってくる
  -  [Setについて >>>](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set)

```diff ts:chat.gateway.ts
   @SubscribeMessage('message')
-  handleMessage(@MessageBody() message: string) {
-    this.logger.log('message recieved');
-    this.server.emit('update', message);
+  handleMessage(
+    @MessageBody() message: string,
+    @ConnectedSocket() socket: Socket,
+  ) {
+    this.logger.log(`message: recieved ${message}`);
+    const rooms = [...socket.rooms].slice(0);
+    this.server.to(rooms[1]).emit('update', message);
   }
+
+  @SubscribeMessage('joinRoom')
+  joinOrUpdateRoom(
+    @MessageBody() roomId: string,
+    @ConnectedSocket() socket: Socket,
+  ) {
+    this.logger.log(`joinRoom: ${socket.id} joined ${roomId}`);
+    const rooms = [...socket.rooms].slice(0);
+    if (rooms.length == 2) socket.leave(rooms[1]);
+    socket.join(roomId);
+  }
 }
```

## c. 3画面で確認する

![](/images/websocket3/2022-08-16-23-28-32.png)

わかりにくいが、、、
- 左と中心のウィンドウがRoom1、右のウィンドウがRoom2に参加している
- 左のウィンドウ、中心のウィンドウ、右のウィンドウの順にメッセージを入力
- Room1に入室しているクライアントには同時に新規メッセージが反映される
- Room2の入力はRoom1のクライアントには反映されない

:::message
これで、同じルームに接続しているClientのみに同時にメッセージを返すことができるようになった👏👏
:::
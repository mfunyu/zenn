---
title: "NestJSとにかく書き始める: 実践編💻"
free: false
---

# 動かし方
```shell
npm run start
```
以下のように`:dev`をつけて実行すると、ファイルを変更するたびに再度起動しなくても、変更を自動で読み込んでくれる（勝手に再コンパイル＆実行してくれるイメージ）
```shell
npm run start:dev
```

# 確認方法
[Postman](https://www.postman.com/)というツールが便利そうですが、普通にcurlでも確認できるので、ここでは馴染みのあるcurlを使用していきます
```shell
curl -X GET http://localhost:3000/users
```

# 1. GETメソッド作成
## a. Controllerに直書きする
https://github.com/mfunyu/pre-transcendence/commit/6d3c007e6cea2f8f322a7425b7c85f900b775361

`users.controller.ts`に新しいメソッドを追加します
一旦簡易的に、ただ文字列を返すだけの関数にします。
```diff ts:users.controller.ts
-import { Controller } from '@nestjs/common';
+import { Controller, Get } from '@nestjs/common';
 
 @Controller('users')
-export class UsersController {}
+export class UsersController {
+       @Get()
+       getAll() {
+               return 'getAll called\n';
+       }
+}
```
実行結果
```shell
$> curl -X GET http://localhost:3000/users
getAll called
```
## b. Serviceに移植する
https://github.com/mfunyu/pre-transcendence/commit/50fb1cb607ea6e1dff144dc275aec33a8e6cb329
このまま`users.controller.ts`に機能追加していっても動作はするのですが、コードの可読性、拡張性を保つために`users.service.ts`に移植します。
今後はそのまま`users.service.ts`に機能の実装を追加していきます

1. `users.controller.ts`にUsersServiceをインポートします
2. `constructor`を定義し、`usersService`という変数を`UsersService`型で宣言します
```diff ts:users.controller.ts
 import { Controller, Get } from '@nestjs/common';
+import { UsersService } from './users.service';
 
 @Controller('users')
 export class UsersController {
+       constructor(private readonly usersService: UsersService){}
+
        @Get()
        getAll() {
                return 'getAll called\n';
        }
 }
 ```
 3. `users.service.ts`にメソッドの定義を追記します
 ```diff ts:users.service.ts
  import { Injectable } from '@nestjs/common';
 
  @Injectable()
-export class UsersService {}
+export class UsersService {
+       getAll() {
+               return 'getAll called\n';
+       }
+}
```
 4. `users.module.ts`からメソッドを呼び出します
```ts diff:users.module.ts
 import { Controller, Get } from '@nestjs/common';
 import { UsersService } from './users.service';
 
 @Controller('users')
 export class UsersController {
        constructor(private readonly usersService: UsersService){}

        @Get()
        getAll() {
-               return 'getAll called\n';
+               return this.usersService.getAll();
        }
 }
 ```
 # 2. モデルを作成
 https://github.com/mfunyu/pre-transcendence/commit/95e0e02a57601b353156767e7b59d0466a2f0379
 
 モデル＝型定義のこと
 C++で言う構造体のようなものでTypeScriptではinterfaceに当たる
 
 必要なデータ構造を作成して`users.model.ts`にinterfaceとして定義する
 ```js:users.model.ts
 export interface User {
	id: string;
	nickname: string;
	password: number;
	level: number;
}
```

## メソッドでモデルを使う
https://github.com/mfunyu/pre-transcendence/commit/5d882adca8c08634775ca43c4272358150e249fd
### a. クラス内に配列を作成する
```diff ts:users.service.ts
 import { Injectable } from '@nestjs/common';
+import { User } from './users.model';
 
 @Injectable()
 export class UsersService {
+       private users: User[] = [];
+
        getAll() {
                return 'getAll called\n';
        }
 }
 ```
 ### b. メソッドで配列を使えるようにする
 `users.service.ts`で戻り値を設定する
 ```diff ts:users.service.ts
  import { Injectable } from '@nestjs/common';
+import { User } from './users.model';
 
 @Injectable()
 export class UsersService {
        private users: User[] = [];

-       getAll() {
-               return 'getAll called\n';
+       getAll(): User[] {
+               return this.users;
        }
 }
 ```
 `users.module.ts`でも戻り値を設定する
```diff ts:users.module.ts
 import { Controller, Get } from '@nestjs/common';
 import { UsersService } from './users.service';
+import { User } from './users.model';
 
 @Controller('users')
 export class UsersController {
        constructor(private readonly usersService: UsersService){}
 
        @Get()
-       getAll() {
+       getAll(): User[] {
                return this.usersService.getAll();
        }
 }
 ```
 
 # 3. POSTメソッドの追加
 https://github.com/mfunyu/pre-transcendence/commit/c44cc863b7da922b212486c786d54c5dc0e20094
`users.module.ts`にメソッドを追加する
- 引数に`@Body('category_name')`を指定することで、HTTP POSTリクエストのリクエストボディーを受け取ることができるようになる。
- User型の変数をリクエストボディーの中身を用いて宣言し、serviceの方の関数に引数として渡す。
- 初期化したUser型変数を戻り値として返す。

```diff ts:users.module.ts
    getAll(): User[] {
     return this.usersService.getAll();
   }
+
+  @Post()
+  addUser(
+    @Body('id') id: string,
+    @Body('nickname') nickname: string,
+    @Body('password') password: string,
+  ): User {
+    const user: User = {
+      id,
+      nickname,
+      password,
+      level: 0,
+    };
+    return this.usersService.addUser(user);
+  }
 }
 ```
 - http://localhost:3000/users にPOSTリクエストを送り、動作を確認する。
 - `-d`を使って、リクエストボディーの値を指定する。
 
 ```shell
 $> curl -X POST http://localhost:3000/users \
 -d id=mfunyu \
 -d nickname=U \
 -d password=d0ntt3llthis2anyone!
```

# 4. 可変パスのリクエストを受けつけるメソッド
 
https://github.com/mfunyu/pre-transcendence/commit/67dca5246f141c079e5cd33d598ac17e9192cec5

### **`users.controller.ts`**
- `@Get('id')`と書くと`http://localhost:3000/users/id`のパスのリクエストのみが該当する
- 可変引数にするためには`:`を変数名の頭につけて`@Get(':id')`と書くことによって`http://localhost:3000/users/mfunyu`, `http://localhost:3000/users/loginId`などのパスのリクエストを受け取ることができるようになる

```diff ts:users.controller.ts
+
+  @Get(':id') // /users/{id}
+  findUser(@Param('id') id: string): User {
+    return this.usersService.findUser(id);
+  }
 }
```
### **`users.servers.ts`**
- users配列から`/users/{id}`のリクエストのidが該当するものを探す
- TypeScriptのアロー関数を使うとシンプルに書ける
- 参考資料

　https://typescriptbook.jp/reference/functions/arrow-functions
https://qiita.com/suin/items/a44825d253d023e31e4d

```diff ts:users.servers.ts
+
+  findUser(id: string): User {
+    return this.users.find((user) => user.id === id);
+  }
 }
```
 
# 5. 他の必要なメソッドの追加

## PATCHメソッド
データをアップデートする時はPATCHメソッドを使用します。

https://github.com/mfunyu/pre-transcendence/commit/e6b32716281941c080c5b85840cd88d9b65714fb
### **`users.controller.ts`**
- `'@nestjs/common'`からPatchをimportする
```diff ts:users.controller.ts
+
+　@Patch(':id')
+  updateLevel(@Param('id') id: string): User {
+    return this.usersService.updateLevel(id);
+  }
}
```
### **`users.servers.ts`**
```diff ts:users.servers.ts
+  updateLevel(id: string): User {
+    const user: User = this.users.find((user) => user.id === id);
+    if (user) user.level++;
+    return user;
+  }
}
```

## DELETEメソッド
データの削除をDELETEを用いて実装します。
https://github.com/mfunyu/pre-transcendence/commit/1e40e807e3c6c790c4ebcfb07092335a63ea4c59
### **`users.controller.ts`**
- `'@nestjs/common'`からDeleteをimportする
```diff ts:users.controller.ts
+
+  @Delete(':id')
+  deleteUser(@Param('id') id: string): void {
+    this.usersService.deleteUser(id);
+  }
}
```
### **`users.servers.ts`**
```diff ts:users.servers.ts
+  deleteUser(id: string): void {
+    this.users = this.users.filter((user) => user.id !== id);
+  }
}
```

--- 

以上で、NextJS実装の基本は終わりです！
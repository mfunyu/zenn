---
title: "プロジェクトセットアップ4：Git Hooksを設定しよう！⛓"
free: false
---

# 参考資料
*"りあクト！ TypeScriptで始めるつらくないReact開発 第3.1版【Ⅱ. React基礎編】" - 第６章*
https://oukayuka.booth.pm/items/2368019
[対応レポジトリ>>>](https://github.com/oukayuka/Riakuto-StartingReact-ja3.1)

# Git Hooksを使ってコミット前に自動チェックしよう！

> **TODO：**
> コミット前にlinterとformatterが走るように設定して、フォーマットし忘れやそのための追加のコミットが発生することを未然に防ごう！


## Git Hooksとは...
- `.git/hooks/`ディレクトリ下のファイルが、各アクションごとに実行される
- 例）`pre-commit`: コミット前に実行されるスクリプト
- 例）`pre-push`: プッシュ前に実行されるスクリプト

:::message
`.git/hooks/`配下に直接ファイルを作成することも可能だが、`.git`配下のファイルはコミットできないので、自動で作成されるように設定する
:::

## 早速設定しよう！
https://github.com/mfunyu/pre-transcendence/commit/489692b9e4abdddf3629124e81e06f55b4f6bcdd

1. `simple-Git-hooks`というツールをインストールする
	- `husky`というツールの方が有名
	- `husky v6`では、`.husky/`ディレクトリ配下にスクリプトを配置する必要があるが、`simple-Git-hooks`では、`package.json`に追記できる
	- [husky v6 vs simple-git-hooks 参考 >>>](https://zenn.dev/t28_tatsuya/articles/should-i-use-husky-or-simple-git-hook)

	```bash
	npm install --save-dev simple-git-hooks lint-staged
	```
2. `package.json`に追記
	-  "simple-git-hooks"に対し、`per-commit`ファイルに`npx lint-staged`を追記するように指定する
	-  コミット前に`npx lint-staged`が実行されるようになる
	 ```diff json:package.json
	     "devDependencies": {
	 	    ...
	    },
	+  "simple-git-hooks": {
	+    "pre-commit": "npx lint-staged"
	+  },
	+  "lint-staged": {
	+    "src/**/*.{js,jsx,ts,tsx}": [
	+      "prettier --write --loglevel=error",
	+      "eslint --fix --quiet"
	+    ],
	+    "{public,src}/**/*.{html,gql,graphql,json}": [
	+      "prettier --write --loglevel=error"
	+    ]
	+  }
	}
	```
3. simple-git-hooksを実行する
	```bash
	npx simple-git-hooks
	```
4. インストール後の自動化を`package.json`に追記
	- 毎回`npx simple-git-hooks`を実行しなくても済むように、`prepare`スクリプトを登録しておく
	 ```diff json:package.json
	    "scripts": {
	     ...
    	  "lint:fix": "eslint --fix 'src/**/*.{js,jsx,ts,tsx}'",
    	  "preinstall": "typesync || :",
	+   "prepare": "simple-git-hooks > /dev/null"
	    },
	 ```
5. Gitレポジトリルートと、プロジェクトのルートが違う場合
	- ルートでシェルスクリプトを実行するようにする
	 ```diff json:package.json
	   "simple-git-hooks": {
	-    "pre-commit": "npx lint-staged"
	+    "pre-commit": ". ./lint-staged-around"
	   },
	}
	```
	- 以下のファイルをコピーしてGitレポジトリルートに`lint-staged-around`ファイルを作成した
	
https://github.com/oukayuka/Riakuto-StartingReact-ja3.1/blob/master/lint-staged-around

6. MacOS用の修正
	- MacOSの場合はコミット実行時に以下のエラーが出るのでファイルを修正する
	```
	sed: illegal option -- r
	usage: sed script [-Ealn] [-i extension] [file ...]
	       sed [-Ealn] [-i extension] [-e script] ... [-f script_file] ... [file ...]
	```
	```diff shell:lint-staged-around
	  else
	 	 against=$(git hash-object -t tree /dev/null)
	  fi
 
	+ if [ "$(uname)" == "Darwin" ]; then
	+        sedOption='-E'
	+ else
	+        sedOption='-r'
	+ fi
	+ 
	  # pick staged projects
	  stagedProjects=$( \
	    git diff --cached --name-only --diff-filter=AM $against | \
	    grep -E ".*($target)\/" | \
	    grep -E "^.*\/.*\.($fileTypes)$" | \
	    grep -vE "(package|tsconfig).*\.json" | \
	-   sed -r "s/($target)\/.*$//g" | \
	+   sed $sedOption "s/($target)\/.*$//g" | \
	    uniq \
	  )
 
	  # execute each lint-staged
	- rootDir=$(pwd | sed -r "s/\/\.git\/hooks//")
	+ rootDir=$(pwd | sed $sedOption "s/\/\.git\/hooks//")
	```


https://github.com/mfunyu/pre-transcendence/commit/1324d52cf40adf9a300b2e71ab07a50681959141

これでコミットするときに、ESlint, Prettierが自動で走って、修正可能な場合は修正した上でコミットすることができるようになりました。



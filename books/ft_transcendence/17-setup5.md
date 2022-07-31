---
title: "CSSは任せよう：Material-UIを理解する"
free: false
---

# 参考資料
*"Implement High Fidelity Designs with Material-UI and ReactJS" - Section1*
https://www.udemy.com/course/implement-high-fidelity-designs-with-material-ui-and-reactjs/

# Material-UIを使ってCSSを一括！

## Why Material-UI?[^1]

[^1]: [Implement High Fidelity Designs with Material-UI and ReactJS - Section1.2](https://mercari.udemy.com/course/implement-high-fidelity-designs-with-material-ui-and-reactjs/learn/lecture/16040442#overview)

- Bootstrap/React-Bootstrap
	- 最も古い
	- 元々はReactのために作られたものではない
	- カスタマイズに制限がある
- Semantic-UI/Semantic-UI-React
	- これも元々はReactのために作られたものではない
	- React対応版も標準ライブラリに依存しているために制限的
- **Material-UI**
	- Reactのためだけに作られたのでReactに最適
	- カスタマイズに柔軟性がある
	- カスタマイズをしても一貫性が保たれる
	- レスポンシブデザインにも簡単に対応できる


## Material-UIをインストールする


- React v18では以下のインストールコマンドは動かない（2022/7 現在）ので
```bash
npm install @material-ui/core
```
- 代わりに
```bash
npm install @mui/material @emotion/react @emotion/styled --legacy-peer-deps
npm install @mui/icons-material --legacy-peer-deps
```
を使ってインストールする

参考↓
https://github.com/mui/material-ui/issues/32074


## 

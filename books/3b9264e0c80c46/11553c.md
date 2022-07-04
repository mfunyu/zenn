---
title: "プロジェクトセットアップ3：ディレクトリ構成📁"
free: false
---

# Container / Presentational構成

| Presentational Component | | Container Component |
| :--: | :--: | :--: |
| `components` | **ディレクトリ名** | `container` | 
| どのように見えるか（UI)　| **関心** | どのように機能するか（ロジック）| 
| 原則持たない | **状態** | 持つ |
| たくさん持つ | **DOMマークアップ** | できるだけ少なく持つ |
| propsでデータを受け取る | **データ** | データを他のコンポーネントに受け渡す |

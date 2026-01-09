# Swipe Arrows (スワイプアロウズ)

## プロジェクト概要

4方向から流れてくる矢印文字を素早くスワイプして飛ばす反射神経ゲーム。
ストループ効果（文字の意味と出現位置の競合）を活かした脳トレ要素を持つ。

## 技術スタック

- **言語**: Swift
- **UI**: SwiftUI
- **最小対応OS**: iOS 17.0
- **バックエンド**: Firebase
  - Authentication (匿名認証 → ニックネーム紐付け)
  - Firestore (ランキング、ユーザー情報)
- **アーキテクチャ**: MVVM

## ゲームルール

### 基本ルール

1. 画面の上下左右から矢印文字が中央に向かって流れてくる
2. プレイヤーは文字に応じた方向にスワイプして飛ばす
3. 誤った方向にスワイプ、または飛ばせずに中央到達でゲームオーバー

### 矢印文字の種類

- 記号: `↑` `→` `↓` `←`
- 漢字: `上` `右` `下` `左`
- ランダムに出現

### 文字色ルール

| 色 | アクション |
|----|------------|
| 黒 | 文字の示す方向にスワイプ |
| 赤 | 文字の示す方向と**逆**にスワイプ |

### 難易度変化

- 時間経過・スコア増加に応じて矢印の移動速度が上昇
- 速度上昇カーブは調整可能にする（定数化）

## ゲームモード

4つのモード（2軸の組み合わせ）:

| モード名 | ルール | 終了条件 |
|----------|--------|----------|
| エンドレス・黒のみ | 黒文字のみ出現 | ミスで終了 |
| エンドレス・黒+赤 | 黒と赤が出現 | ミスで終了 |
| タイムアタック・黒のみ | 黒文字のみ出現 | 60秒経過 |
| タイムアタック・黒+赤 | 黒と赤が出現 | 60秒経過 |

※ タイムアタックでもミスしたら即終了

## スコアシステム

- スコア = 飛ばした矢印の数
- コンボボーナスなし（シンプルにカウント）
- 各モードごとにベストスコアを保存
- 各モードごとにオンラインランキング

## 画面構成

```
├── スプラッシュ画面
├── タイトル画面
│   ├── ゲームスタート → モード選択
│   ├── ランキング
│   └── 設定
├── モード選択画面
│   ├── ルール選択 (黒のみ / 黒+赤)
│   └── モード選択 (エンドレス / タイムアタック)
├── ゲーム画面
│   ├── スコア表示
│   ├── 残り時間 (タイムアタック時)
│   └── ゲームエリア
├── リザルト画面
│   ├── スコア表示
│   ├── ベストスコア更新通知
│   └── ランキング確認 / リトライ / タイトルへ
├── ランキング画面
│   └── モード別タブ切り替え
├── ニックネーム登録画面 (初回起動時)
└── 設定画面
    ├── ニックネーム変更
    └── 振動ON/OFF
```

## Firebase設計

### Firestore構造

```
users/
  {userId}/
    nickname: string
    createdAt: timestamp
    updatedAt: timestamp

rankings/
  {modeId}/
    scores/
      {odcId}/
        userId: string
        nickname: string (非正規化)
        score: number
        createdAt: timestamp

# modeId: "endless_black", "endless_mixed", "timeattack_black", "timeattack_mixed"
```

### セキュリティルール方針

- ユーザーは自分のデータのみ書き込み可
- ランキングは誰でも読み取り可
- スコア書き込みは認証済みユーザーのみ

## 演出・フィードバック

### Haptic Feedback

- 正解スワイプ: 軽い成功フィードバック (`.success`)
- ミス: 短いエラーフィードバック (`.error`)
- ゲームオーバー: 強めの通知 (`.notification`)

### 視覚エフェクト (Phase 1: シンプル)

- スワイプ成功: 矢印が飛んでいくアニメーション + フェードアウト
- ミス: 画面フラッシュ（赤）
- スコア更新: 数字のスケールアニメーション

### 効果音 (将来対応)

- Phase 1では実装しない
- 将来的に追加予定

## ディレクトリ構成

```
SwipeArrows/
├── App/
│   └── SwipeArrowsApp.swift
├── Models/
│   ├── Arrow.swift
│   ├── GameMode.swift
│   ├── GameState.swift
│   └── User.swift
├── ViewModels/
│   ├── GameViewModel.swift
│   ├── RankingViewModel.swift
│   └── UserViewModel.swift
├── Views/
│   ├── Title/
│   │   └── TitleView.swift
│   ├── ModeSelect/
│   │   └── ModeSelectView.swift
│   ├── Game/
│   │   ├── GameView.swift
│   │   ├── ArrowView.swift
│   │   └── GameOverlayView.swift
│   ├── Result/
│   │   └── ResultView.swift
│   ├── Ranking/
│   │   └── RankingView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       └── (共通コンポーネント)
├── Services/
│   ├── FirebaseService.swift
│   ├── AuthService.swift
│   └── HapticService.swift
├── Utilities/
│   ├── Constants.swift
│   └── Extensions/
├── Resources/
│   └── Assets.xcassets
└── GoogleService-Info.plist
```

## 開発フェーズ

### Phase 1: MVP (コア機能)

1. プロジェクトセットアップ + Firebase連携
2. ニックネーム登録画面
3. タイトル画面 + モード選択画面
4. ゲーム画面（コアゲームループ）
   - 矢印の生成・移動
   - スワイプ判定
   - スコアカウント
   - ゲームオーバー判定
5. リザルト画面
6. ローカルベストスコア保存
7. Haptic Feedback実装

### Phase 2: オンライン機能

1. Firestoreランキング保存
2. ランキング画面
3. セキュリティルール設定

### Phase 3: 演出強化

1. 視覚エフェクト改善
2. 効果音追加
3. アニメーション調整

### Phase 4: リリース準備

1. App Store用スクリーンショット
2. プライバシーポリシー
3. App Store Connect設定
4. TestFlight配布

## コーディング規約

### 命名規則

- 型名: UpperCamelCase (`GameViewModel`)
- 変数・関数: lowerCamelCase (`currentScore`)
- 定数: lowerCamelCase (`maxSpeed`)
- 列挙型のcase: lowerCamelCase (`case endless`)

### SwiftUI

- Viewは可能な限り小さく分割
- プレビュー用のモックデータを用意
- `@StateObject`はViewで生成、`@ObservedObject`は親から受け取る

### コメント

- 複雑なロジックには日本語コメント可
- TODOは `// TODO:` 形式で記載
- 公開APIにはDocコメント推奨

## 調整可能なパラメータ (Constants.swift)

```swift
enum GameConfig {
    static let initialArrowSpeed: CGFloat = 200  // 初期速度 (pt/sec)
    static let maxArrowSpeed: CGFloat = 600      // 最大速度
    static let speedIncreaseRate: CGFloat = 1.1  // 速度上昇率
    static let speedIncreaseInterval: Int = 10   // 何個ごとに速度UP
    static let timeAttackDuration: TimeInterval = 60  // タイムアタック秒数
    static let arrowSpawnInterval: TimeInterval = 1.5 // 矢印出現間隔（初期）
    static let minSpawnInterval: TimeInterval = 0.5   // 最小出現間隔
}
```

## 注意事項

- ゲーム中の状態管理は`GameViewModel`に集約
- 矢印の出現位置（上下左右）と文字の方向は独立してランダム
- スワイプ判定は画面全体で受け付ける（矢印の位置に関係なく）
- 複数の矢印が同時に存在する場合、最も中央に近いものから判定

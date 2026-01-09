//
//  Constants.swift
//  swipe-arrows
//

import Foundation
import SwiftUI
import UIKit

enum GameConfig {
    static let initialArrowSpeed: CGFloat = 120     // 初期速度 (pt/sec) → 約1.5秒
    static let maxArrowSpeed: CGFloat = 236         // 最大速度 → 約0.75秒
    static let speedIncreaseRate: CGFloat = 1.08    // 速度上昇率
    static let speedIncreaseInterval: Int = 5       // 何個ごとに速度UP
    static let timeAttackDuration: TimeInterval = 60  // タイムアタック秒数
    static let arrowSpawnInterval: TimeInterval = 1.5 // 矢印出現間隔（初期）
    static let minSpawnInterval: TimeInterval = 0.5   // 最小出現間隔
    static let arrowSize: CGFloat = 44              // 矢印のサイズ
    static let centerZoneRadius: CGFloat = 20       // 中央判定エリアの半径
    static let swipeThreshold: CGFloat = 50         // スワイプと判定する最小距離
    static let fixedGameAreaSize: CGFloat = 350     // 固定ゲームエリアサイズ（全端末共通）
}

enum AppColors {
    // ネオン系カラーパレット
    static let background = Color(red: 0.04, green: 0.04, blue: 0.1) // ダークネイビー
    static let backgroundGradientTop = Color(red: 0.05, green: 0.05, blue: 0.15)
    static let backgroundGradientBottom = Color(red: 0.02, green: 0.02, blue: 0.08)

    static let neonCyan = Color(red: 0, green: 0.96, blue: 1)       // #00f5ff - メイン
    static let neonMagenta = Color(red: 1, green: 0, blue: 1)       // #ff00ff - アクセント
    static let neonPink = Color(red: 1, green: 0, blue: 0.4)        // #ff0066 - 警告/赤矢印
    static let neonGreen = Color(red: 0, green: 1, blue: 0.53)      // #00ff88 - 成功
    static let neonYellow = Color(red: 1, green: 1, blue: 0)        // #ffff00

    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.6)
    static let accentColor = neonCyan
    static let dangerColor = neonPink
}

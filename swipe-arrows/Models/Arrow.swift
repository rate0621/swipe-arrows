//
//  Arrow.swift
//  swipe-arrows
//

import Foundation
import SwiftUI

struct Arrow: Identifiable {
    let id = UUID()
    let direction: Direction       // 文字が示す方向（スワイプすべき方向の基準）
    let spawnDirection: Direction  // 矢印が出現する方向（画面のどの端から出るか）
    let isRed: Bool                // 赤文字かどうか（赤なら逆方向にスワイプ）
    let useKanji: Bool             // 漢字を使うかどうか
    var position: CGPoint          // 現在位置
    let createdAt: Date = Date()

    // 正解のスワイプ方向
    var correctSwipeDirection: Direction {
        isRed ? direction.opposite : direction
    }

    // 表示する文字
    var displayCharacter: String {
        useKanji ? direction.kanjiCharacter : direction.symbolCharacter
    }

    // 表示色（ネオン系）
    var displayColor: Color {
        isRed ? AppColors.neonPink : AppColors.neonCyan
    }
}

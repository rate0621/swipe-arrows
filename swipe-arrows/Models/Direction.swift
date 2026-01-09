//
//  Direction.swift
//  swipe-arrows
//

import Foundation

enum Direction: CaseIterable {
    case up
    case down
    case left
    case right

    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    // 矢印記号
    var symbolCharacter: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        case .left: return "←"
        case .right: return "→"
        }
    }

    // 漢字
    var kanjiCharacter: String {
        switch self {
        case .up: return "上"
        case .down: return "下"
        case .left: return "左"
        case .right: return "右"
        }
    }
}

//
//  GameMode.swift
//  swipe-arrows
//

import Foundation

// ルールタイプ（黒のみ or 黒+赤）
enum RuleType: String, CaseIterable, Identifiable {
    case blackOnly = "black_only"
    case mixed = "mixed"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .blackOnly: return "ノーマル"
        case .mixed: return "ハード"
        }
    }

    var description: String {
        switch self {
        case .blackOnly: return "指示された方向にスワイプ"
        case .mixed: return "赤文字の場合は逆方向にスワイプ"
        }
    }
}

// ゲームモードタイプ（エンドレス or タイムアタック）
enum ModeType: String, CaseIterable, Identifiable {
    case endless = "endless"
    case timeAttack = "timeattack"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .endless: return "エンドレス"
        case .timeAttack: return "タイムアタック"
        }
    }

    var description: String {
        switch self {
        case .endless: return "ミスするまで続く"
        case .timeAttack: return "60秒間でハイスコアを目指す"
        }
    }
}

// 4つのゲームモードの組み合わせ
struct GameMode: Identifiable, Equatable {
    let ruleType: RuleType
    let modeType: ModeType

    var id: String {
        "\(modeType.rawValue)_\(ruleType.rawValue)"
    }

    var displayName: String {
        "\(modeType.displayName)・\(ruleType.displayName)"
    }

    // Firestoreのモード識別子に対応
    var firestoreModeId: String {
        switch (modeType, ruleType) {
        case (.endless, .blackOnly): return "endless_black"
        case (.endless, .mixed): return "endless_mixed"
        case (.timeAttack, .blackOnly): return "timeattack_black"
        case (.timeAttack, .mixed): return "timeattack_mixed"
        }
    }

    static func == (lhs: GameMode, rhs: GameMode) -> Bool {
        lhs.id == rhs.id
    }
}

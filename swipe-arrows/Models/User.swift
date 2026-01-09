//
//  User.swift
//  swipe-arrows
//

import Foundation

struct User: Codable, Identifiable {
    var id: String  // Firebase UID (ローカルではUUID)
    var nickname: String
    var createdAt: Date
    var updatedAt: Date

    init(id: String = UUID().uuidString, nickname: String) {
        self.id = id
        self.nickname = nickname
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// ベストスコアの保存用
struct BestScores: Codable {
    var endlessBlack: Int = 0
    var endlessMixed: Int = 0
    var timeattackBlack: Int = 0
    var timeattackMixed: Int = 0

    mutating func updateScore(for mode: GameMode, score: Int) -> Bool {
        let currentBest = getScore(for: mode)
        if score > currentBest {
            setScore(for: mode, score: score)
            return true
        }
        return false
    }

    func getScore(for mode: GameMode) -> Int {
        switch mode.firestoreModeId {
        case "endless_black": return endlessBlack
        case "endless_mixed": return endlessMixed
        case "timeattack_black": return timeattackBlack
        case "timeattack_mixed": return timeattackMixed
        default: return 0
        }
    }

    private mutating func setScore(for mode: GameMode, score: Int) {
        switch mode.firestoreModeId {
        case "endless_black": endlessBlack = score
        case "endless_mixed": endlessMixed = score
        case "timeattack_black": timeattackBlack = score
        case "timeattack_mixed": timeattackMixed = score
        default: break
        }
    }
}

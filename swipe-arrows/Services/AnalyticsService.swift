//
//  AnalyticsService.swift
//  swipe-arrows
//
//  Firebase Analytics用のサービス
//

import Foundation
import FirebaseAnalytics

enum AnalyticsService {

    // MARK: - Game Events

    /// ゲーム開始時に呼び出し
    static func logGameStart(ruleType: String, modeType: String) {
        Analytics.logEvent("game_start", parameters: [
            "rule_type": ruleType,
            "mode_type": modeType
        ])
    }

    /// ゲーム終了時に呼び出し
    static func logGameEnd(ruleType: String, modeType: String, score: Int) {
        Analytics.logEvent("game_end", parameters: [
            "rule_type": ruleType,
            "mode_type": modeType,
            "score": score
        ])
    }

    /// ハイスコア更新時に呼び出し
    static func logNewHighScore(ruleType: String, modeType: String, score: Int) {
        Analytics.logEvent("new_high_score", parameters: [
            "rule_type": ruleType,
            "mode_type": modeType,
            "score": score
        ])
    }
}

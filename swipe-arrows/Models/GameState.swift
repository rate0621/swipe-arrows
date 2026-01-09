//
//  GameState.swift
//  swipe-arrows
//

import Foundation

enum GamePhase {
    case ready      // ゲーム開始前
    case playing    // プレイ中
    case gameOver   // ゲームオーバー
}

struct GameState {
    var phase: GamePhase = .ready
    var score: Int = 0
    var arrows: [Arrow] = []
    var currentSpeed: CGFloat = GameConfig.initialArrowSpeed
    var currentSpawnInterval: TimeInterval = GameConfig.arrowSpawnInterval
    var remainingTime: TimeInterval = GameConfig.timeAttackDuration
    var isNewHighScore: Bool = false

    mutating func reset() {
        phase = .ready
        score = 0
        arrows = []
        currentSpeed = GameConfig.initialArrowSpeed
        currentSpawnInterval = GameConfig.arrowSpawnInterval
        remainingTime = GameConfig.timeAttackDuration
        isNewHighScore = false
    }
}

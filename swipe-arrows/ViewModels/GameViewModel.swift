//
//  GameViewModel.swift
//  swipe-arrows
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published var state = GameState()
    @Published var screenSize: CGSize = .zero
    @Published var showMissFlash: Bool = false

    var gameMode: GameMode = GameMode(ruleType: .blackOnly, modeType: .endless)

    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: CFTimeInterval = 0
    private var arrowsCleared: Int = 0

    private let haptic = HapticService.shared

    // 固定サイズのゲームエリア（全端末で同じサイズ）
    var gameAreaSize: CGFloat {
        GameConfig.fixedGameAreaSize
    }

    var gameAreaOrigin: CGPoint {
        CGPoint(
            x: (screenSize.width - gameAreaSize) / 2,
            y: (screenSize.height - gameAreaSize) / 2
        )
    }

    var gameAreaCenter: CGPoint {
        CGPoint(
            x: screenSize.width / 2,
            y: screenSize.height / 2
        )
    }

    // MARK: - Game Control

    func startGame() {
        state.reset()
        state.phase = .playing
        arrowsCleared = 0

        // デバッグ設定を反映
        #if DEBUG
        let debug = DebugSettings.shared
        if debug.useCustomSpeed {
            state.currentSpeed = debug.customInitialSpeed
        }
        // 開始スコアが設定されている場合、速度を調整
        if debug.startFromScore > 0 {
            arrowsCleared = debug.startFromScore
            state.score = debug.startFromScore
            // スコアに応じた速度に調整
            let increments = debug.startFromScore / GameConfig.speedIncreaseInterval
            for _ in 0..<increments {
                state.currentSpeed = min(
                    state.currentSpeed * GameConfig.speedIncreaseRate,
                    debug.useCustomSpeed ? debug.customMaxSpeed : GameConfig.maxArrowSpeed
                )
            }
        }
        #endif

        startTimers()
        spawnArrow()
    }

    func pauseGame() {
        stopTimers()
    }

    func resumeGame() {
        guard state.phase == .playing else { return }
        startTimers()
    }

    func endGame() {
        stopTimers()
        state.phase = .gameOver
        haptic.playGameOver()
    }

    // MARK: - Swipe Handling

    func handleSwipe(direction: Direction) {
        guard state.phase == .playing else { return }
        guard !state.arrows.isEmpty else { return }

        // 最も中央に近い矢印を取得
        guard let closestArrow = getClosestArrowToCenter() else { return }

        if closestArrow.correctSwipeDirection == direction {
            // 正解
            haptic.playSuccess()
            removeArrow(closestArrow)
            state.score += 1
            arrowsCleared += 1
            updateDifficulty()
            // すぐに次の矢印を出現させ、タイマーをリセット
            spawnArrow()
            scheduleNextSpawn()
        } else {
            // ミス
            triggerMiss()
        }
    }

    private func getClosestArrowToCenter() -> Arrow? {
        return state.arrows.min { a, b in
            distanceToCenter(a.position, center: gameAreaCenter) < distanceToCenter(b.position, center: gameAreaCenter)
        }
    }

    private func distanceToCenter(_ point: CGPoint, center: CGPoint) -> CGFloat {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx * dx + dy * dy)
    }

    private func removeArrow(_ arrow: Arrow) {
        state.arrows.removeAll { $0.id == arrow.id }
    }

    private func triggerMiss() {
        haptic.playError()
        showMissFlash = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.showMissFlash = false
        }

        endGame()
    }

    // MARK: - Arrow Generation

    private func spawnArrow() {
        guard state.phase == .playing else { return }
        // 既に矢印がある場合はスポーンしない（1つずつ処理）
        guard state.arrows.isEmpty else { return }

        let spawnDirection = Direction.allCases.randomElement()!
        let textDirection = Direction.allCases.randomElement()!
        let isRed = gameMode.ruleType == .mixed && Bool.random()
        let useKanji = Bool.random()

        let position = calculateSpawnPosition(for: spawnDirection)

        let arrow = Arrow(
            direction: textDirection,
            spawnDirection: spawnDirection,
            isRed: isRed,
            useKanji: useKanji,
            position: position
        )

        state.arrows.append(arrow)
    }

    private func calculateSpawnPosition(for direction: Direction) -> CGPoint {
        let padding: CGFloat = GameConfig.arrowSize / 2
        let halfSize = gameAreaSize / 2

        switch direction {
        case .up:
            return CGPoint(x: gameAreaCenter.x, y: gameAreaCenter.y - halfSize - padding)
        case .down:
            return CGPoint(x: gameAreaCenter.x, y: gameAreaCenter.y + halfSize + padding)
        case .left:
            return CGPoint(x: gameAreaCenter.x - halfSize - padding, y: gameAreaCenter.y)
        case .right:
            return CGPoint(x: gameAreaCenter.x + halfSize + padding, y: gameAreaCenter.y)
        }
    }

    // MARK: - Game Loop

    private func startTimers() {
        // ゲームループ用のDisplayLink
        displayLink = CADisplayLink(target: self, selector: #selector(updateGame))
        displayLink?.add(to: .main, forMode: .common)
        lastUpdateTime = CACurrentMediaTime()

        // 矢印スポーンタイマー
        scheduleNextSpawn()

        // タイムアタックモードの場合、残り時間を減らすタイマー
        if gameMode.modeType == .timeAttack {
            gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.updateRemainingTime()
                }
            }
        }
    }

    private func stopTimers() {
        displayLink?.invalidate()
        displayLink = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
    }

    private func scheduleNextSpawn() {
        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: state.currentSpawnInterval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.spawnArrow()
                self?.scheduleNextSpawn()
            }
        }
    }

    @objc private func updateGame() {
        guard state.phase == .playing else { return }

        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        updateArrowPositions(deltaTime: deltaTime)
        checkCenterCollision()
    }

    private func updateArrowPositions(deltaTime: CFTimeInterval) {
        for i in state.arrows.indices {
            let arrow = state.arrows[i]
            let movement = CGFloat(deltaTime) * state.currentSpeed

            // 中央に向かって移動
            let dx = gameAreaCenter.x - arrow.position.x
            let dy = gameAreaCenter.y - arrow.position.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance > 0 {
                let normalizedDx = dx / distance
                let normalizedDy = dy / distance
                state.arrows[i].position.x += normalizedDx * movement
                state.arrows[i].position.y += normalizedDy * movement
            }
        }
    }

    private func checkCenterCollision() {
        for arrow in state.arrows {
            let distance = distanceToCenter(arrow.position, center: gameAreaCenter)
            if distance < GameConfig.centerZoneRadius {
                // 中央に到達 → ゲームオーバー
                triggerMiss()
                return
            }
        }
    }

    private func updateRemainingTime() {
        guard state.phase == .playing else { return }
        state.remainingTime -= 0.1

        if state.remainingTime <= 0 {
            state.remainingTime = 0
            endGame()
        }
    }

    // MARK: - Difficulty

    private func updateDifficulty() {
        // スコアに応じて速度を上げる
        if arrowsCleared > 0 && arrowsCleared % GameConfig.speedIncreaseInterval == 0 {
            var maxSpeed = GameConfig.maxArrowSpeed
            #if DEBUG
            if DebugSettings.shared.useCustomSpeed {
                maxSpeed = DebugSettings.shared.customMaxSpeed
            }
            #endif

            state.currentSpeed = min(
                state.currentSpeed * GameConfig.speedIncreaseRate,
                maxSpeed
            )

            // スポーン間隔も短くする
            state.currentSpawnInterval = max(
                state.currentSpawnInterval * 0.95,
                GameConfig.minSpawnInterval
            )
        }
    }
}

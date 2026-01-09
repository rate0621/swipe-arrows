//
//  UserViewModel.swift
//  swipe-arrows
//

import Foundation
import SwiftUI
import Combine
import StoreKit

@MainActor
final class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var bestScores: BestScores = BestScores()
    @Published var isHapticEnabled: Bool = true
    @Published var totalArrowsCleared: Int = 0
    @Published var totalGamesPlayed: Int = 0

    private let userKey = "currentUser"
    private let scoresKey = "bestScores"
    private let totalArrowsKey = "totalArrowsCleared"
    private let gamesPlayedKey = "totalGamesPlayed"
    private let hasRequestedReviewKey = "hasRequestedReview"

    init() {
        loadUser()
        loadBestScores()
        loadTotalArrows()
        loadGamesPlayed()
        isHapticEnabled = HapticService.shared.loadEnabled()
    }

    // MARK: - User Management

    var hasUser: Bool {
        user != nil
    }

    var nickname: String {
        user?.nickname ?? ""
    }

    func createUser(nickname: String) {
        let newUser = User(nickname: nickname)
        user = newUser
        saveUser()
    }

    func updateNickname(_ nickname: String) {
        user?.nickname = nickname
        user?.updatedAt = Date()
        saveUser()
    }

    private func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let savedUser = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        user = savedUser
    }

    private func saveUser() {
        guard let user = user,
              let data = try? JSONEncoder().encode(user) else {
            return
        }
        UserDefaults.standard.set(data, forKey: userKey)
    }

    // MARK: - Score Management

    func updateBestScore(for mode: GameMode, score: Int) -> Bool {
        let isNewBest = bestScores.updateScore(for: mode, score: score)
        if isNewBest {
            saveBestScores()
        }
        return isNewBest
    }

    func getBestScore(for mode: GameMode) -> Int {
        bestScores.getScore(for: mode)
    }

    private func loadBestScores() {
        guard let data = UserDefaults.standard.data(forKey: scoresKey),
              let savedScores = try? JSONDecoder().decode(BestScores.self, from: data) else {
            return
        }
        bestScores = savedScores
    }

    private func saveBestScores() {
        guard let data = try? JSONEncoder().encode(bestScores) else {
            return
        }
        UserDefaults.standard.set(data, forKey: scoresKey)
    }

    // MARK: - Settings

    func setHapticEnabled(_ enabled: Bool) {
        isHapticEnabled = enabled
        HapticService.shared.setEnabled(enabled)
    }

    // MARK: - Total Arrows

    func addArrowsCleared(_ count: Int) {
        totalArrowsCleared += count
        saveTotalArrows()
    }

    private func loadTotalArrows() {
        totalArrowsCleared = UserDefaults.standard.integer(forKey: totalArrowsKey)
    }

    private func saveTotalArrows() {
        UserDefaults.standard.set(totalArrowsCleared, forKey: totalArrowsKey)
    }

    // MARK: - Games Played & Review Request

    func incrementGamesPlayed() {
        totalGamesPlayed += 1
        saveGamesPlayed()
        checkAndRequestReview()
    }

    private func loadGamesPlayed() {
        totalGamesPlayed = UserDefaults.standard.integer(forKey: gamesPlayedKey)
    }

    private func saveGamesPlayed() {
        UserDefaults.standard.set(totalGamesPlayed, forKey: gamesPlayedKey)
    }

    private func checkAndRequestReview() {
        let hasRequested = UserDefaults.standard.bool(forKey: hasRequestedReviewKey)

        // 10回プレイかつまだレビュー依頼していない場合
        if totalGamesPlayed == 10 && !hasRequested {
            requestReview()
            UserDefaults.standard.set(true, forKey: hasRequestedReviewKey)
        }
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

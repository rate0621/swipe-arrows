//
//  HapticService.swift
//  swipe-arrows
//

import UIKit

final class HapticService {
    static let shared = HapticService()

    private let successFeedback = UIImpactFeedbackGenerator(style: .light)
    private let errorFeedback = UINotificationFeedbackGenerator()

    private var isEnabled: Bool = true

    private init() {
        // ジェネレータの準備
        successFeedback.prepare()
        errorFeedback.prepare()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "hapticEnabled")
    }

    func loadEnabled() -> Bool {
        if UserDefaults.standard.object(forKey: "hapticEnabled") == nil {
            return true // デフォルトは有効
        }
        isEnabled = UserDefaults.standard.bool(forKey: "hapticEnabled")
        return isEnabled
    }

    // 正解スワイプ時
    func playSuccess() {
        guard isEnabled else { return }
        successFeedback.impactOccurred()
        successFeedback.prepare()
    }

    // ミス時
    func playError() {
        guard isEnabled else { return }
        errorFeedback.notificationOccurred(.error)
        errorFeedback.prepare()
    }

    // ゲームオーバー時
    func playGameOver() {
        guard isEnabled else { return }
        errorFeedback.notificationOccurred(.warning)
        errorFeedback.prepare()
    }
}

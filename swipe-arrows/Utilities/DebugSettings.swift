//
//  DebugSettings.swift
//  swipe-arrows
//
//  DEBUGビルド時のみ使用するデバッグ設定
//

import Foundation
import Combine

#if DEBUG
@MainActor
final class DebugSettings: ObservableObject {
    static let shared = DebugSettings()

    @Published var useCustomSpeed: Bool = false
    @Published var customInitialSpeed: CGFloat = 120
    @Published var customMaxSpeed: CGFloat = 250
    @Published var startFromScore: Int = 0  // 指定スコアからスタート（速度テスト用）

    private init() {}

    var effectiveInitialSpeed: CGFloat {
        useCustomSpeed ? customInitialSpeed : GameConfig.initialArrowSpeed
    }

    var effectiveMaxSpeed: CGFloat {
        useCustomSpeed ? customMaxSpeed : GameConfig.maxArrowSpeed
    }
}
#endif

//
//  ResultView.swift
//  swipe-arrows
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen
    let gameMode: GameMode
    let score: Int
    let isNewHighScore: Bool

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 32) {
                Spacer()

                // ゲームオーバーテキスト
                Text("GAME OVER")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(AppColors.secondaryText)

                // スコア表示
                VStack(spacing: 8) {
                    Text("SCORE")
                        .font(.headline)
                        .foregroundColor(AppColors.secondaryText)

                    Text("\(score)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.neonCyan)
                        .neonGlow(color: AppColors.neonCyan, radius: 8)

                    if isNewHighScore {
                        Text("NEW BEST!")
                            .font(.headline)
                            .foregroundColor(AppColors.neonYellow)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.neonYellow, lineWidth: 2)
                                    .background(AppColors.neonYellow.opacity(0.2).cornerRadius(8))
                            )
                            .neonGlow(color: AppColors.neonYellow, radius: 4)
                    }
                }

                // ベストスコア
                VStack(spacing: 4) {
                    Text("BEST")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text("\(userViewModel.getBestScore(for: gameMode))")
                        .font(.title)
                        .foregroundColor(AppColors.neonMagenta)
                        .neonGlow(color: AppColors.neonMagenta, radius: 4)
                }

                // モード表示
                Text(gameMode.displayName)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)

                Spacer()

                // ボタン
                VStack(spacing: 12) {
                    NeonFilledButton(title: "リトライ", color: AppColors.neonCyan) {
                        currentScreen = .game
                    }
                    .padding(.horizontal, 32)

                    NeonButton(title: "モード選択", color: AppColors.neonCyan) {
                        currentScreen = .modeSelect
                    }

                    Button(action: {
                        currentScreen = .title
                    }) {
                        Text("タイトルへ")
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ResultView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.result),
        gameMode: GameMode(ruleType: .blackOnly, modeType: .endless),
        score: 42,
        isNewHighScore: true
    )
}

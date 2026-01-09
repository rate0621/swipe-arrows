//
//  RankingView.swift
//  swipe-arrows
//

import SwiftUI

struct RankingView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen

    @State private var selectedModeType: ModeType = .endless
    @State private var selectedRuleType: RuleType = .blackOnly

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button(action: { currentScreen = .title }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(AppColors.neonCyan)
                    }
                    Spacer()
                    Text("ランキング")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding()

                // モード選択タブ
                VStack(spacing: 12) {
                    // ルールタイプ
                    HStack(spacing: 12) {
                        ForEach(RuleType.allCases) { rule in
                            NeonTabButton(
                                title: rule.displayName,
                                isSelected: selectedRuleType == rule,
                                color: rule == .mixed ? AppColors.neonPink : AppColors.neonCyan
                            ) {
                                selectedRuleType = rule
                            }
                        }
                    }

                    // モードタイプ
                    HStack(spacing: 12) {
                        ForEach(ModeType.allCases) { mode in
                            NeonTabButton(
                                title: mode.displayName,
                                isSelected: selectedModeType == mode,
                                color: AppColors.neonCyan
                            ) {
                                selectedModeType = mode
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // ベストスコア表示
                let currentMode = GameMode(ruleType: selectedRuleType, modeType: selectedModeType)
                let bestScore = userViewModel.getBestScore(for: currentMode)

                VStack(spacing: 16) {
                    Text("あなたのベスト")
                        .font(.headline)
                        .foregroundColor(AppColors.secondaryText)

                    Text("\(bestScore)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.neonCyan)
                        .neonGlow(color: AppColors.neonCyan, radius: 6)

                    Text(currentMode.displayName)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }

                Spacer()

                Text("オンラインランキングは\n今後のアップデートで追加予定")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Neon Tab Button

struct NeonTabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? color : AppColors.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? color : AppColors.secondaryText.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? color.opacity(0.15) : Color.clear)
                        )
                )
                .neonGlow(color: isSelected ? color : .clear, radius: 4)
        }
    }
}

#Preview {
    RankingView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.ranking)
    )
}

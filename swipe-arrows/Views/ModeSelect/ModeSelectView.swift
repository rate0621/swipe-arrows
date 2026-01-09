//
//  ModeSelectView.swift
//  swipe-arrows
//

import SwiftUI

struct ModeSelectView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen
    @Binding var selectedMode: GameMode

    @State private var selectedRuleType: RuleType = .blackOnly
    @State private var selectedModeType: ModeType = .endless

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 24) {
                // ヘッダー
                HStack {
                    Button(action: { currentScreen = .title }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(AppColors.neonCyan)
                    }
                    Spacer()
                    Text("モード選択")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 24) {
                        // ルール選択
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ルール")
                                .font(.headline)
                                .foregroundColor(AppColors.secondaryText)

                            ForEach(RuleType.allCases) { rule in
                                NeonOptionButton(
                                    title: rule.displayName,
                                    description: rule.description,
                                    isSelected: selectedRuleType == rule,
                                    bestScore: userViewModel.getBestScore(
                                        for: GameMode(ruleType: rule, modeType: selectedModeType)
                                    ),
                                    color: rule == .mixed ? AppColors.neonPink : AppColors.neonCyan
                                ) {
                                    selectedRuleType = rule
                                }
                            }
                        }

                        // モードタイプ選択
                        VStack(alignment: .leading, spacing: 12) {
                            Text("モード")
                                .font(.headline)
                                .foregroundColor(AppColors.secondaryText)

                            ForEach(ModeType.allCases) { mode in
                                NeonOptionButton(
                                    title: mode.displayName,
                                    description: mode.description,
                                    isSelected: selectedModeType == mode,
                                    bestScore: userViewModel.getBestScore(
                                        for: GameMode(ruleType: selectedRuleType, modeType: mode)
                                    ),
                                    color: AppColors.neonCyan
                                ) {
                                    selectedModeType = mode
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // スタートボタン
                NeonFilledButton(title: "スタート", color: AppColors.neonCyan) {
                    selectedMode = GameMode(ruleType: selectedRuleType, modeType: selectedModeType)
                    currentScreen = .game
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Neon Option Button

struct NeonOptionButton: View {
    let title: String
    let description: String
    let isSelected: Bool
    let bestScore: Int
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? color : AppColors.primaryText)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                }

                Spacer()

                if bestScore > 0 {
                    Text("Best: \(bestScore)")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? color : AppColors.secondaryText)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : AppColors.secondaryText.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? color.opacity(0.15) : Color.clear)
                    )
            )
            .neonGlow(color: isSelected ? color : .clear, radius: 6)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ModeSelectView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.modeSelect),
        selectedMode: .constant(GameMode(ruleType: .blackOnly, modeType: .endless))
    )
}

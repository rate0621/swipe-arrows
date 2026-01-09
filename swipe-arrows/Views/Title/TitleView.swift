//
//  TitleView.swift
//  swipe-arrows
//

import SwiftUI

struct TitleView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 40) {
                Spacer()

                // タイトル
                VStack(spacing: 4) {
                    Text("SWIPE")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primaryText)
                    Text("ARROWS")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.neonCyan)
                        .neonGlow(color: AppColors.neonCyan, radius: 6)
                }

                Text("↑ → ↓ ←")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.neonMagenta)
                    .neonGlow(color: AppColors.neonMagenta, radius: 4)

                Spacer()

                // メニューボタン
                VStack(spacing: 16) {
                    NeonFilledButton(title: "ゲームスタート", color: AppColors.neonCyan) {
                        currentScreen = .modeSelect
                    }
                    .padding(.horizontal, 32)

                    NeonButton(title: "ランキング", color: AppColors.neonCyan) {
                        currentScreen = .ranking
                    }

                    NeonButton(title: "設定", color: AppColors.secondaryText) {
                        currentScreen = .settings
                    }
                }

                Spacer()

                // ニックネーム表示
                if userViewModel.hasUser {
                    Text("プレイヤー: \(userViewModel.nickname)")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TitleView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.title)
    )
}

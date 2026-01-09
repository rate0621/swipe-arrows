//
//  GameOverlayView.swift
//  swipe-arrows
//

import SwiftUI

struct GameOverlayView: View {
    let score: Int
    let remainingTime: TimeInterval?
    let onPause: () -> Void

    var body: some View {
        HStack {
            // スコア
            VStack(alignment: .leading) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(AppColors.secondaryText)
                Text("\(score)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.neonCyan)
                    .neonGlow(color: AppColors.neonCyan, radius: 6)
                    .contentTransition(.numericText())
            }

            Spacer()

            // 残り時間（タイムアタック時のみ）
            if let time = remainingTime {
                VStack(alignment: .trailing) {
                    Text("TIME")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                    Text(String(format: "%.1f", time))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(time <= 10 ? AppColors.neonPink : AppColors.neonGreen)
                        .neonGlow(color: time <= 10 ? AppColors.neonPink : AppColors.neonGreen, radius: 6)
                        .contentTransition(.numericText())
                }
            }
        }
        .padding()
        .padding(.top, 8)
    }
}

#Preview {
    ZStack {
        NeonBackground()

        VStack {
            GameOverlayView(score: 42, remainingTime: nil, onPause: {})
            GameOverlayView(score: 42, remainingTime: 45.3, onPause: {})
            GameOverlayView(score: 42, remainingTime: 5.2, onPause: {})
        }
    }
}

//
//  NeonStyles.swift
//  swipe-arrows
//
//  ネオン系デザイン用の共通コンポーネント
//

import SwiftUI

// MARK: - Neon Background

struct NeonBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AppColors.backgroundGradientTop, AppColors.backgroundGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Neon Text Modifier

struct NeonGlow: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.4), radius: radius / 2)
            .shadow(color: color.opacity(0.2), radius: radius)
    }
}

extension View {
    func neonGlow(color: Color = AppColors.neonCyan, radius: CGFloat = 10) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }
}

// MARK: - Neon Button

struct NeonButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    init(title: String, color: Color = AppColors.neonCyan, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                        .background(color.opacity(0.1).cornerRadius(12))
                )
                .neonGlow(color: color, radius: 4)
        }
        .frame(maxWidth: 280)
    }
}

// MARK: - Neon Filled Button

struct NeonFilledButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    init(title: String, color: Color = AppColors.neonCyan, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(AppColors.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color)
                )
                .neonGlow(color: color, radius: 6)
        }
    }
}

// MARK: - Neon Card

struct NeonCard<Content: View>: View {
    let color: Color
    let isSelected: Bool
    let content: Content

    init(color: Color = AppColors.neonCyan, isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.color = color
        self.isSelected = isSelected
        self.content = content()
    }

    var body: some View {
        content
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
}

// MARK: - Preview

#Preview {
    ZStack {
        NeonBackground()

        VStack(spacing: 24) {
            Text("SWIPE ARROWS")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .neonGlow(color: AppColors.neonCyan)

            NeonButton(title: "ゲームスタート") {}

            NeonFilledButton(title: "スタート") {}

            NeonCard(isSelected: true) {
                Text("選択されたカード")
                    .foregroundColor(.white)
            }

            NeonCard(isSelected: false) {
                Text("未選択のカード")
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

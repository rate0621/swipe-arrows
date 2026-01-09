//
//  SettingsView.swift
//  swipe-arrows
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen

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
                    Text("設定")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding()

                VStack(spacing: 16) {
                    // ニックネーム
                    Button(action: {
                        currentScreen = .nickname
                    }) {
                        HStack {
                            Text("ニックネーム")
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                            Text(userViewModel.nickname)
                                .foregroundColor(AppColors.secondaryText)
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.secondaryText)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.secondaryText.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // 振動設定
                    HStack {
                        Text("振動")
                            .foregroundColor(AppColors.primaryText)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { userViewModel.isHapticEnabled },
                            set: { userViewModel.setHapticEnabled($0) }
                        ))
                        .tint(AppColors.neonCyan)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.secondaryText.opacity(0.3), lineWidth: 1)
                    )

                    // 累計矢印数
                    HStack {
                        Text("累計スワイプ数")
                            .foregroundColor(AppColors.primaryText)
                        Spacer()
                        Text("\(userViewModel.totalArrowsCleared)")
                            .foregroundColor(AppColors.neonCyan)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.secondaryText.opacity(0.3), lineWidth: 1)
                    )

                    // プライバシーポリシー
                    Button(action: {
                        if let url = URL(string: "https://github.com/rate/swipe-arrows/blob/main/PRIVACY_POLICY.md") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("プライバシーポリシー")
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(AppColors.secondaryText)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.secondaryText.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // バージョン
                    HStack {
                        Text("バージョン")
                            .foregroundColor(AppColors.primaryText)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.secondaryText.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

#Preview {
    SettingsView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.settings)
    )
}

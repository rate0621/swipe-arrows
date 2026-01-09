//
//  NicknameView.swift
//  swipe-arrows
//

import SwiftUI

struct NicknameView: View {
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen
    let isEditing: Bool

    @State private var nickname: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 32) {
                if isEditing {
                    HStack {
                        Button(action: { currentScreen = .settings }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(AppColors.neonCyan)
                        }
                        Spacer()
                        Text("ニックネーム変更")
                            .font(.title2.bold())
                            .foregroundColor(AppColors.primaryText)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .opacity(0)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 8) {
                    Text(isEditing ? "新しいニックネーム" : "ニックネームを入力")
                        .font(.title2.bold())
                        .foregroundColor(AppColors.primaryText)

                    Text("ランキングに表示されます")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }

                TextField("ニックネーム", text: $nickname)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.neonCyan, lineWidth: 2)
                            .background(AppColors.background.cornerRadius(12))
                    )
                    .foregroundColor(AppColors.primaryText)
                    .frame(maxWidth: 280)
                    .focused($isTextFieldFocused)
                    .onAppear {
                        if isEditing {
                            nickname = userViewModel.nickname
                        }
                        isTextFieldFocused = true
                    }

                if nickname.count > 12 {
                    Text("12文字以内で入力してください")
                        .font(.caption)
                        .foregroundColor(AppColors.neonPink)
                }

                Spacer()

                NeonFilledButton(
                    title: isEditing ? "変更する" : "はじめる",
                    color: isValidNickname ? AppColors.neonCyan : AppColors.secondaryText
                ) {
                    saveNickname()
                }
                .disabled(!isValidNickname)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var isValidNickname: Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 1 && trimmed.count <= 12
    }

    private func saveNickname() {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        if isEditing {
            userViewModel.updateNickname(trimmed)
            currentScreen = .settings
        } else {
            userViewModel.createUser(nickname: trimmed)
            currentScreen = .title
        }
    }
}

#Preview("New User") {
    NicknameView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.nickname),
        isEditing: false
    )
}

#Preview("Edit") {
    NicknameView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.nickname),
        isEditing: true
    )
}

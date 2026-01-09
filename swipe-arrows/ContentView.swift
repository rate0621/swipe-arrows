//
//  ContentView.swift
//  swipe-arrows
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var currentScreen: AppScreen = .splash
    @State private var selectedMode: GameMode = GameMode(ruleType: .blackOnly, modeType: .endless)
    @State private var lastScore: Int = 0
    @State private var isNewHighScore: Bool = false

    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                SplashView()
                    .onAppear {
                        // スプラッシュ後の遷移先を決定
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                if userViewModel.hasUser {
                                    currentScreen = .title
                                } else {
                                    currentScreen = .nickname
                                }
                            }
                        }
                    }

            case .nickname:
                NicknameView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen,
                    isEditing: userViewModel.hasUser
                )
                .transition(.move(edge: .trailing))

            case .title:
                TitleView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen
                )
                .transition(.opacity)

            case .modeSelect:
                ModeSelectView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen,
                    selectedMode: $selectedMode
                )
                .transition(.move(edge: .trailing))

            case .game:
                GameContainerView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen,
                    selectedMode: selectedMode,
                    lastScore: $lastScore,
                    isNewHighScore: $isNewHighScore
                )
                .transition(.opacity)

            case .result:
                ResultView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen,
                    gameMode: selectedMode,
                    score: lastScore,
                    isNewHighScore: isNewHighScore
                )
                .transition(.move(edge: .bottom))

            case .ranking:
                RankingView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen
                )
                .transition(.move(edge: .trailing))

            case .settings:
                SettingsView(
                    userViewModel: userViewModel,
                    currentScreen: $currentScreen
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreen)
    }
}

// MARK: - Splash View

struct SplashView: View {
    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 16) {
                Text("↑ → ↓ ←")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppColors.neonCyan)
                    .neonGlow(color: AppColors.neonCyan)

                Text("SWIPE ARROWS")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
}

// MARK: - Game Container View
// GameViewのラッパー（スコアの受け渡し用）

struct GameContainerView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen
    let selectedMode: GameMode
    @Binding var lastScore: Int
    @Binding var isNewHighScore: Bool

    @State private var countdownValue: Int = 3
    @State private var isCountingDown: Bool = true
    @State private var showGo: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2

            ZStack {
                // 背景
                NeonBackground()

                // 中央のターゲット（カウントダウン中は非表示）
                if !isCountingDown && !showGo {
                    Circle()
                        .stroke(AppColors.neonCyan.opacity(0.5), lineWidth: 2)
                        .frame(width: GameConfig.centerZoneRadius * 2,
                               height: GameConfig.centerZoneRadius * 2)
                        .neonGlow(color: AppColors.neonCyan, radius: 6)
                        .position(x: centerX, y: centerY)
                }

                // 矢印（カウントダウン中は非表示）
                if !isCountingDown && !showGo {
                    ForEach(gameViewModel.state.arrows) { arrow in
                        ArrowView(arrow: arrow)
                    }
                }

                // ミス時の赤フラッシュ
                if gameViewModel.showMissFlash {
                    AppColors.neonPink.opacity(0.3)
                        .ignoresSafeArea()
                }

                // カウントダウン表示
                if isCountingDown {
                    Text("\(countdownValue)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.neonCyan)
                        .neonGlow(color: AppColors.neonCyan, radius: 10)
                } else if showGo {
                    Text("GO!")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.neonGreen)
                        .neonGlow(color: AppColors.neonGreen, radius: 10)
                }

                // オーバーレイUI（カウントダウン中は非表示）
                if !isCountingDown && !showGo {
                    VStack {
                        GameOverlayView(
                            score: gameViewModel.state.score,
                            remainingTime: selectedMode.modeType == .timeAttack ? gameViewModel.state.remainingTime : nil,
                            onPause: {
                                gameViewModel.pauseGame()
                            }
                        )

                        Spacer()
                    }
                }
            }
            .onAppear {
                gameViewModel.screenSize = geometry.size
                gameViewModel.gameMode = selectedMode
                startCountdown()
            }
            .gesture(isCountingDown || showGo ? nil : swipeGesture)
            .onChange(of: gameViewModel.state.phase) { _, newPhase in
                if newPhase == .gameOver {
                    handleGameOver()
                }
            }
        }
    }

    // MARK: - Countdown

    private func startCountdown() {
        countdownValue = 3
        isCountingDown = true
        showGo = false

        // 3 -> 2 -> 1 -> GO! -> Start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            countdownValue = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            countdownValue = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            isCountingDown = false
            showGo = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            showGo = false
            gameViewModel.startGame()
        }
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: GameConfig.swipeThreshold)
            .onEnded { value in
                let direction = detectSwipeDirection(value.translation)
                gameViewModel.handleSwipe(direction: direction)
            }
    }

    private func detectSwipeDirection(_ translation: CGSize) -> Direction {
        let absX = abs(translation.width)
        let absY = abs(translation.height)

        if absX > absY {
            return translation.width > 0 ? .right : .left
        } else {
            return translation.height > 0 ? .down : .up
        }
    }

    // MARK: - Game Over

    private func handleGameOver() {
        lastScore = gameViewModel.state.score
        isNewHighScore = userViewModel.updateBestScore(for: selectedMode, score: lastScore)
        userViewModel.addArrowsCleared(lastScore)
        userViewModel.incrementGamesPlayed()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentScreen = .result
        }
    }
}

#Preview {
    ContentView()
}

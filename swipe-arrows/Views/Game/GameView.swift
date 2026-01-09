//
//  GameView.swift
//  swipe-arrows
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @ObservedObject var userViewModel: UserViewModel
    @Binding var currentScreen: AppScreen
    let gameMode: GameMode

    @State private var lastScore: Int = 0
    @State private var isNewHighScore: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                // 中央のターゲット
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: GameConfig.centerZoneRadius * 2,
                           height: GameConfig.centerZoneRadius * 2)
                    .position(x: geometry.size.width / 2,
                              y: geometry.size.height / 2)

                // 矢印
                ForEach(viewModel.state.arrows) { arrow in
                    ArrowView(arrow: arrow)
                }

                // ミス時の赤フラッシュ
                if viewModel.showMissFlash {
                    Color.red.opacity(0.3)
                        .ignoresSafeArea()
                }

                // オーバーレイUI
                VStack {
                    GameOverlayView(
                        score: viewModel.state.score,
                        remainingTime: gameMode.modeType == .timeAttack ? viewModel.state.remainingTime : nil,
                        onPause: {
                            viewModel.pauseGame()
                        }
                    )

                    Spacer()
                }
            }
            .onAppear {
                viewModel.screenSize = geometry.size
                viewModel.gameMode = gameMode
                viewModel.startGame()
            }
            .gesture(swipeGesture)
            .onChange(of: viewModel.state.phase) { _, newPhase in
                if newPhase == .gameOver {
                    handleGameOver()
                }
            }
        }
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: GameConfig.swipeThreshold)
            .onEnded { value in
                let direction = detectSwipeDirection(value.translation)
                viewModel.handleSwipe(direction: direction)
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
        lastScore = viewModel.state.score
        isNewHighScore = userViewModel.updateBestScore(for: gameMode, score: lastScore)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentScreen = .result
        }
    }
}

#Preview {
    GameView(
        userViewModel: UserViewModel(),
        currentScreen: .constant(.game),
        gameMode: GameMode(ruleType: .blackOnly, modeType: .endless)
    )
}

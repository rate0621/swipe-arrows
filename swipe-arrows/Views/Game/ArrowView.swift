//
//  ArrowView.swift
//  swipe-arrows
//

import SwiftUI

struct ArrowView: View {
    let arrow: Arrow

    var body: some View {
        Text(arrow.displayCharacter)
            .font(.system(size: GameConfig.arrowSize, weight: .bold))
            .foregroundColor(arrow.displayColor)
            .neonGlow(color: arrow.displayColor, radius: 6)
            .position(arrow.position)
    }
}

#Preview {
    ZStack {
        NeonBackground()

        ArrowView(
            arrow: Arrow(
                direction: .up,
                spawnDirection: .down,
                isRed: false,
                useKanji: false,
                position: CGPoint(x: 200, y: 300)
            )
        )

        ArrowView(
            arrow: Arrow(
                direction: .right,
                spawnDirection: .left,
                isRed: true,
                useKanji: true,
                position: CGPoint(x: 200, y: 450)
            )
        )
    }
}

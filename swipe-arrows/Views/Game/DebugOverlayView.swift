//
//  DebugOverlayView.swift
//  swipe-arrows
//
//  DEBUGビルド時のみ表示されるデバッグ設定UI（モード選択画面用）
//

import SwiftUI

#if DEBUG
struct DebugSettingsView: View {
    @ObservedObject var debugSettings = DebugSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "ladybug.fill")
                    .foregroundColor(.orange)
                Text("Debug Settings")
                    .font(.headline)
            }

            Toggle("カスタム速度", isOn: $debugSettings.useCustomSpeed)
                .font(.subheadline)

            if debugSettings.useCustomSpeed {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("初期速度:")
                            .font(.caption)
                        Text("\(Int(debugSettings.customInitialSpeed)) pt/s")
                            .font(.caption.monospaced())
                        Spacer()
                        Text("≈\(String(format: "%.1f", 175 / debugSettings.customInitialSpeed))秒")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $debugSettings.customInitialSpeed, in: 50...300, step: 10)

                    HStack {
                        Text("最大速度:")
                            .font(.caption)
                        Text("\(Int(debugSettings.customMaxSpeed)) pt/s")
                            .font(.caption.monospaced())
                        Spacer()
                        Text("≈\(String(format: "%.1f", 175 / debugSettings.customMaxSpeed))秒")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $debugSettings.customMaxSpeed, in: 100...400, step: 10)

                    HStack {
                        Text("開始スコア:")
                            .font(.caption)
                        Text("\(debugSettings.startFromScore)")
                            .font(.caption.monospaced())
                    }
                    Slider(value: Binding(
                        get: { Double(debugSettings.startFromScore) },
                        set: { debugSettings.startFromScore = Int($0) }
                    ), in: 0...50, step: 5)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    DebugSettingsView()
        .padding()
}
#endif

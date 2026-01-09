//
//  swipe_arrowsApp.swift
//  swipe-arrows
//
//  Created by rate on 2026/01/08.
//

import SwiftUI
import FirebaseCore

@main
struct swipe_arrowsApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

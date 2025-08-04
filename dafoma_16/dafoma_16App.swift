//
//  dafoma_16App.swift
//  dafoma_16
//
//  Created by Вячеслав on 8/4/25.
//

import SwiftUI

@main
struct FlavorQuestApp: App {
    @StateObject private var gameManager = GameManager()
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(userSettings)
                .preferredColorScheme(.dark)
        }
    }
}

//
//  EgenBoysApp.swift
//  EgenBoys
//
//  Created by 이건준 on 8/8/25.
//

import SwiftUI
import SwiftData

@main
struct EgenBoysApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(settingsViewModel)
                .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [Quiz.self, Question.self])
    }
}

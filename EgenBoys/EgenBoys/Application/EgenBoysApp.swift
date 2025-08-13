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
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Quiz.self, Question.self])
    }
}

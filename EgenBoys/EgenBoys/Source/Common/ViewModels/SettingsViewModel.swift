//
//  SettingsViewModel.swift
//  EgenBoys
//
//  Created by 구현모 on 8/13/25.
//

import SwiftUI

enum ThemeMode: String, CaseIterable {
    case system = "시스템 설정"
    case light = "라이트"
    case dark = "다크"
}

class SettingsViewModel: ObservableObject {
    @AppStorage("themeMode") var themeMode: ThemeMode = .system
    @AppStorage("fontSize") var fontSize: Double = 16
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

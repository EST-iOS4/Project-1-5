//
//  SettingsViewModel.swift
//  EgenBoys
//
//  Created by 구현모 on 8/13/25.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("fontSize") var fontSize: Double = 16
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
}

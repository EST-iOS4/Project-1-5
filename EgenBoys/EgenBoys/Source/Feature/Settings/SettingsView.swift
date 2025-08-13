//
//  SettingsView.swift
//  EgenBoys
//
//  Created by 구현모 on 8/13/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @State private var temporaryFontSize: Double
    
    init(settingsViewModel: SettingsViewModel) {
        _temporaryFontSize = State(initialValue: settingsViewModel.fontSize)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("테마 설정") {
                    Toggle("다크 모드", isOn: $settings.isDarkMode)
                }
                Section(header: Text("폰트 크기")) {
                    Slider(value: $temporaryFontSize, in: 12...30, step: 1)
                    Text("폰트 크기 미리보기 (\(Int(temporaryFontSize))pt)")
                        .font(.system(size: CGFloat(temporaryFontSize)))
                }
            }
            .navigationTitle("설정")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        settings.fontSize = temporaryFontSize
                    }
                }
            }
        }
    }
}


struct SettingsPreviewWrapper: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        SettingsView(settingsViewModel: settingsViewModel)
            .environmentObject(settingsViewModel)
            .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
    }
}
#Preview {
    SettingsPreviewWrapper()
}

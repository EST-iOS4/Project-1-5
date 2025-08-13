//
//  SettingsView.swift
//  EgenBoys
//
//  Created by 구현모 on 8/13/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowingSaveAlert = false
    @State private var temporaryFontSize: Double = 16.0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("테마 설정") {
                    Toggle("다크 모드", isOn: $settings.isDarkMode)
                }
                Section(header: Text("폰트 크기")) {
                    Slider(value: $temporaryFontSize, in: 12...24, step: 1)
                    Text("폰트 크기 미리보기 (\(Int(temporaryFontSize))pt)")
                        .font(.system(size: CGFloat(temporaryFontSize)))
                }
            }
            .navigationTitle("설정")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") {
                        settings.fontSize = temporaryFontSize
                        isShowingSaveAlert = true
                    }
                }
            }
            .onAppear {
                temporaryFontSize = settings.fontSize
            }
        }
        .alert("저장 완료", isPresented: $isShowingSaveAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("설정이 저장되었습니다.")
        }
    }
}


struct SettingsPreviewWrapper: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        SettingsView()
            .environmentObject(settingsViewModel)
            .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
    }
}
#Preview {
    SettingsPreviewWrapper()
}

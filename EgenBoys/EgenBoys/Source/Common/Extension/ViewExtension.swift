//
//  View+Extension.swift
//  EgenBoys
//
//  Created by 구현모 on 8/13/25.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    @EnvironmentObject var settings: SettingsViewModel
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(settings.fontSize)))
    }
}

extension View {
    func withCustomFont() -> some View {
        self.modifier(CustomFontModifier())
    }
}

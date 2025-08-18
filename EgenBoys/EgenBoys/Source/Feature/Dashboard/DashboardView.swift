//
//  DashboardView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("대시보드 화면")
            }
            .navigationTitle(Text("대시보드"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Text("설정")
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}

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
struct RecentAllView: View {
    let rows: [RecentRow]
    var body: some View {
        List {
            ForEach(rows) { row in
                RecentRowView(row: row)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .listStyle(.plain)
        .navigationTitle("최근 세션 전체")
    }
}
        }
    }
}

#Preview {
    DashboardView()
}

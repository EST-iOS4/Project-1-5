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
struct ScoreRingCard: View {
    var score: Double // 0~100
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(score/100, 0), 1)))
                    .stroke(.blue, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.smooth(duration: 0.6), value: score)
                VStack(spacing: 2) {
                    Text(String(format: "%.0f", score))
                        .font(.title).bold()
                    Text("평균 점수")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(width: 124, height: 124)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.pie.fill")
                    Text("전체 평균 점수")
                        .font(.subheadline).fontWeight(.semibold)
                }
                ProgressView(value: min(max(score/100, 0), 1))
                Text("최근 성과를 기반으로 산출됩니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.separator, lineWidth: 0.6)
        )
    }
}

struct RecentRowView: View {
    let row: RecentRow
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.12))
                Image(systemName: "doc.text.magnifyingglass")
                    .imageScale(.medium)
                    .foregroundStyle(.blue)
            }
            .frame(width: 46, height: 46)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(row.title)
                    .font(.subheadline).fontWeight(.semibold)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(row.date, style: .date)
                    Text("·")
                    Text("\(row.correct)/\(row.total) 정답")
                    if let s = row.durationSec {
                        Text("·"); Text("\(s)s")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(row.accuracy * 100))%")
                .font(.subheadline).bold()
                .frame(minWidth: 44, alignment: .trailing)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.separator, lineWidth: 0.6)
        )
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

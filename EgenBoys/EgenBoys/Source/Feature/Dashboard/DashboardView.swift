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
// MARK: - 통계 계산 (sessions 기반)
struct DashboardStats {
    var totalSessions: Int
    var totalQuestions: Int
    var totalCorrect: Int
    var accuracy: Double   // 전체 문항 기준 정답 비율 (0.0 ~ 1.0)
    var avgScore: Double   // 세션별 점수의 평균 (0.0 ~ 100.0)

    static func from(sessions: [QuizSession]) -> DashboardStats {
        let totalSessions = sessions.count

        // 전체 문항/정답
        let questionCounts = sessions.map { s -> (total: Int, correct: Int) in
            let total = s.items.count
            let correct = s.items.filter(\.isCorrect).count
            return (total, correct)
        }
        let totalQuestions = questionCounts.reduce(0) { $0 + $1.total }
        let totalCorrect = questionCounts.reduce(0) { $0 + $1.correct }
        let accuracy = totalQuestions == 0 ? 0 : Double(totalCorrect) / Double(totalQuestions)

        // 세션별 점수(정답/문항 * 100)의 평균 (세션 가중치 동일)
        let perSessionScores: [Double] = sessions.map { s in
            let total = max(1, s.items.count)
            let correct = s.items.filter(\.isCorrect).count
            return (Double(correct) / Double(total)) * 100.0
        }
        let avgScore = perSessionScores.isEmpty
            ? 0
            : perSessionScores.reduce(0, +) / Double(perSessionScores.count)

        return .init(
            totalSessions: totalSessions,
            totalQuestions: totalQuestions,
            totalCorrect: totalCorrect,
            accuracy: accuracy,
            avgScore: avgScore
        )
    }
}
struct StatCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.system(size: 28, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 96)
        .padding(.vertical, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.separator, lineWidth: 0.6)
        )
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

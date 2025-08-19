//
//  DashboardView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

//  DashboardView.swift
//  EgenBoys

import SwiftUI
import SwiftData

// MARK: - Dashboard (SwiftData: QuizSession 사용)
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext

    // 최근 것이 먼저 보이도록 정렬
    @Query(sort: \QuizSession.startedAt, order: .reverse)
    private var allSessions: [QuizSession]

    enum RangeFilter: String, CaseIterable, Identifiable {
        case all = "전체"
        case last7 = "최근 7일"
        case last30 = "최근 30일"
        var id: String { rawValue }
    }
    @State private var range: RangeFilter = .all

    // ✅ 범위 필터링
    private var filteredSessions: [QuizSession] {
        switch range {
        case .all:
            print("세션: \(allSessions)")
            return allSessions
        case .last7:
            let from = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? .distantPast
            return allSessions.filter { $0.startedAt >= from }
        case .last30:
            let from = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? .distantPast
            return allSessions.filter { $0.startedAt >= from }
        }
    }

    // ✅ 통계 계산 (sessions 기반)
    private var stats: DashboardStats {
        DashboardStats.from(sessions: filteredSessions)
    }

    // ✅ 최근 세션 목록 (세션 날짜 순)
    private var recentRows: [RecentRow] {
        filteredSessions.prefix(10).map { s in
            let total = s.items.count
            let correct = s.items.filter(\.isCorrect).count
            return RecentRow(
                id: s.id.uuidString,
                title: s.title,
                date: s.startedAt,
                correct: correct,
                total: total,
                durationSec: nil // 세션에 지속시간 필드가 있으면 연결
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // 헤더
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("대시보드")
                                .font(.system(size: 34, weight: .bold))
                            Text("앱 전체 결과 요약")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        Spacer()
                        // 설정 버튼 (원래 Picker 자리에)
                        NavigationLink(destination: SettingsView()) {
                            Label("설정", systemImage: "gearshape")
                                .font(.subheadline.weight(.semibold))
                                .labelStyle(.titleAndIcon)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                        }
                    }

                    // KPI 4-Grid
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14),
                                  GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        StatCard(title: "총 풀이 세션", value: "\(stats.totalSessions)")
                        StatCard(title: "총 문제 수",   value: "\(stats.totalQuestions)")
                        StatCard(title: "정답 수",     value: "\(stats.totalCorrect)")
                        StatCard(title: "평균 정답률", value: "\(Int(stats.accuracy * 100))%")
                    }

                    // 전체 평균 점수(세션별 점수의 평균)
                    ScoreRingCard(score: stats.avgScore)

                    // 최근 세션
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("최근 세션")
                                .font(.title3).fontWeight(.semibold)
                            Spacer()
                            NavigationLink("전체 보기") {
                                RecentAllView(rows: recentRows)
                            }
                            .font(.footnote)
                        }

                        VStack(spacing: 12) {
                            ForEach(recentRows.prefix(5)) { row in
                                RecentRowView(row: row)
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 26)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
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

// MARK: - Row 모델 (변경 없음)
struct RecentRow: Identifiable, Hashable {
    let id: String
    let title: String
    let date: Date
    let correct: Int
    let total: Int
    let durationSec: Int?
    var accuracy: Double { total == 0 ? 0 : Double(correct) / Double(total) }
}

// MARK: - 컴포넌트 (StatCard / ScoreRingCard / RecentRowView / RecentAllView 그대로 사용)


// MARK: - 컴포넌트

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

// MARK: - 편의: Quiz에 고유 ID 문자열 생성
private extension Quiz {
    var idString: String {
        // SwiftData 모델이라도 고유 문자열이 필요할 때 대비
        if let any = (self as AnyObject) as? CustomStringConvertible {
            return String(describing: any)
        }
        return UUID().uuidString
    }
}

// MARK: - Preview
#Preview {
    NavigationStack { DashboardView() }
        .preferredColorScheme(.light)
}

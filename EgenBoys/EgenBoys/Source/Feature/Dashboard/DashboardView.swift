//
//  DashboardView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/18/25.
//
import SwiftUI
import SwiftData

// MARK: - Dashboard (SwiftData 연결: Quiz만 사용)
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext

    // ⚠️ 정렬키 제거: 존재하지 않는 modifiedAt/createdAt을 사용하면 크래시남
    @Query private var quizzes: [Quiz]

    enum RangeFilter: String, CaseIterable, Identifiable {
        case all = "전체"
        case last7 = "최근 7일"   // 세션 모델 생기면 활성화
        case last30 = "최근 30일" // 세션 모델 생기면 활성화
        var id: String { rawValue }
    }
    @State private var range: RangeFilter = .all

    // 통계 계산(현재는 퀴즈의 정답표시 개수 기반)
    private var stats: DashboardStats {
        DashboardStats.from(quizzes: filteredQuizzes)
    }

    // 최근 항목: 날짜가 없으므로 “문항 수가 많은 순 → 제목순”으로 대체 정렬
    private var recentRows: [RecentRow] {
        filteredQuizzes
            .sorted { lhs, rhs in
                if lhs.questions.count != rhs.questions.count {
                    return lhs.questions.count > rhs.questions.count
                }
                return lhs.title < rhs.title
            }
            .prefix(10)
            .map { quiz in
                let correct = quiz.questions.filter { $0.isCorrect }.count
                let total   = quiz.questions.count
                return RecentRow(
                    id: quiz.idString,
                    title: quiz.title,
                    date: Date(), // 세션 날짜가 없으니 오늘 날짜로 표시(플레이 세션 연결 시 교체)
                    correct: correct,
                    total: total,
                    durationSec: nil
                )
            }
    }

    // 현재는 범위 필터가 의미 없음(세션 모델 없기 때문) → all만 반환
    private var filteredQuizzes: [Quiz] {
        switch range {
        case .all:    return quizzes
        case .last7:  return quizzes   // TODO: 세션 모델 생기면 날짜 기준 필터
        case .last30: return quizzes   // TODO: 세션 모델 생기면 날짜 기준 필터
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
                        Picker("Range", selection: $range) {
                            ForEach(RangeFilter.allCases) { r in
                                Text(r.rawValue).tag(r)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // KPI 4-Grid (가운데 정렬 + 동일 높이)
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

                    // 평균 점수 카드
                    ScoreRingCard(score: stats.avgScore)

                    // 최근 세션(대체 정렬)
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
                // 요청한 여백: 상하좌우 넉넉하게
                .padding(.horizontal, 22)
                .padding(.vertical, 26)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 통계 계산
struct DashboardStats {
    var totalSessions: Int
    var totalQuestions: Int
    var totalCorrect: Int
    var accuracy: Double   // 0.0 ~ 1.0
    var avgScore: Double   // 0.0 ~ 100.0

    static func from(quizzes: [Quiz]) -> DashboardStats {
        let totalSessions = quizzes.count
        let pairs = quizzes.map { (correct: $0.questions.filter { $0.isCorrect }.count,
                                   total:   $0.questions.count) }
        let totalCorrect   = pairs.reduce(0) { $0 + $1.correct }
        let totalQuestions = pairs.reduce(0) { $0 + $1.total }
        let acc = totalQuestions == 0 ? 0 : Double(totalCorrect) / Double(totalQuestions)
        return .init(
            totalSessions: totalSessions,
            totalQuestions: totalQuestions,
            totalCorrect: totalCorrect,
            accuracy: acc,
            avgScore: acc * 100
        )
    }
}

// MARK: - Row 모델
struct RecentRow: Identifiable, Hashable {
    let id: String
    let title: String
    let date: Date
    let correct: Int
    let total: Int
    let durationSec: Int?
    var accuracy: Double { total == 0 ? 0 : Double(correct) / Double(total) }
}

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

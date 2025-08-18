# EgenBoys – Quiz App

iOS 17+ • SwiftUI • SwiftData • AVKit  
카테고리/난이도별 퀴즈를 풀고, 결과 요약을 시트로 확인하는 앱입니다.

---

## ✨ 주요 기능

- **퀴즈 목록**: 카테고리(Segmented) 필터로 빠른 탐색
- **퀴즈 상세**: 대표 이미지, 설명, 태그(카테고리/난이도/문항), 소개 영상(옵션), 하단 고정 CTA(이 퀴즈 풀기)
- **풀이 화면**: 복수 정답 지원, 항목 피드백(정답/오답/디밍), 진행도 표시, 요약 시트
- **목 데이터**: 버튼 한 번으로 SwiftData에 Seed

---

## 🛠 기술 스택

- **언어/런타임**: Swift 5.9+, iOS 17+
- **UI**: SwiftUI
- **데이터**: SwiftData (`@Model`, `@Query`, 관계/삭제 규칙)
- **미디어**: AVKit(VideoPlayer)
- **아키텍처**: View + Model(간단 계층), 상태관리(State/Binding)

---

## 📁 디렉토리 구조

```swift
|EgenBoys
| | |Source
| | | |Common
| | | | |UI
| | | | | |TabItemView.swift
| | | | | |EBImageView.swift
| | | | |Extension
| | | | |Util
| | | | | |CacheManager.swift # 이미지/데이터 캐싱 등 유틸리티
| | | | |Model # 도메인 모델
| | | | | |Question.swift
| | | | | |Quiz.swift
| | | |Feature
| | | | |QuizList # 목록 + 카테고리 필터 + Seed 버튼
| | | | |MainTabView.swift # 주요 탭 구성 및 라우팅
| | | | |Settings # 앱 설정 화면
| | | | |QuizEditor # 퀴즈 작성/편집 기능(에디터)
| | | | |QuizPlay # 퀴즈 풀이 플로우(질문/선택/정답 확인/요약)
| | | | |Dashboard # 통계/요약 등 대시보드 화면
| | |Application
| | | |EgenBoysApp.swift
| | |Resource
| | | |Assets.xcassets
```

---

## ▶️ 실행 방법

1. **Xcode 15+**에서 프로젝트 열기
2. 대상 기기: **iOS 17+**
3. **Run (⌘R)**

> **목 데이터 넣기(필수)**  
> `QuizListView` 하단의 **“데이터 추가하기”** 버튼을 누르면 예제 퀴즈 7개가 SwiftData에 저장됩니다.

## 📸 메인 탭 미리보기

| 퀴즈 목록                                                     | 퀴즈 상세                                                   | 풀이 화면                                                 | 대시보드                                                       |
| ------------------------------------------------------------- | ----------------------------------------------------------- | --------------------------------------------------------- | -------------------------------------------------------------- |
| <img src="./docs/screenshots/tab-quizlist.png" width="250" /> | <img src="./docs/screenshots/tab-detail.png" width="250" /> | <img src="./docs/screenshots/tab-play.png" width="250" /> | <img src="./docs/screenshots/tab-dashboard.png" width="250" /> |

//
//  QuizEditorView.swift
//  EgenBoys
//
//  Created by 구현모 on 8/12/25.
//

import SwiftUI
import PhotosUI // PhotosPicker 사용을 위해 import
import AVKit // VideoPlayer 사용을 위해 import

enum MediaType {
    case image
    case video
}

struct AnswerOption: Identifiable {
    let id = UUID()
    var text: String = ""
    var isCorrect: Bool = false
}

struct CreateQuestion {
    var questionText: String = ""
    var description: String = ""
    var answerOptions: [AnswerOption] = [
        AnswerOption(),
        AnswerOption(),
        AnswerOption(),
        AnswerOption()
    ]
}

struct QuizEditorView: View {
    @State private var newQuestion = CreateQuestion()
    
    @State private var selectedDifficulty: Difficulty = .medium
    
    @State private var selectedCategory: QuizCategory = .ios
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedMediaItems: [MediaItem] = []
    
    struct MediaItem: Identifiable {
        let id = UUID()
        let type: MediaType
        let data: Data
        var previewURL: URL?
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("문제 및 설명") {
                    VStack {
                        TextField("문제를 입력하세요.", text: $newQuestion.questionText, axis: .vertical)
                            .autocorrectionDisabled()
                            .padding(.vertical, 8)
                        Divider()
                        TextField("문제에 대한 설명을 입력하세요.", text: $newQuestion.description, axis: .vertical)
                            .autocorrectionDisabled()
                            .padding(.vertical, 20)
                    }
                }
                
                Section("보기 및 정답 체크") {
                    VStack {
                        ForEach($newQuestion.answerOptions) { $option in
                            HStack {
                                if let index = newQuestion.answerOptions.firstIndex(where: { $0.id == option.id }) {
                                    Text("\(index + 1).")
                                        .foregroundColor(.gray)
                                }
                                TextField("선택지를 입력하세요.", text: $option.text)
                                    .autocorrectionDisabled()
                                    .padding(.vertical, 5)
                                Button(action: {
                                    option.isCorrect.toggle()
                                }) {
                                    Image(systemName: option.isCorrect ? "checkmark.square.fill" : "square")
                                }
                                .buttonStyle(.plain)
                                
                                if newQuestion.answerOptions.count > 2 {
                                    Button(action: {
                                        removeAnswer(option: option)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                            Divider()
                        }
                        Button(action: addAnswer) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("보기 추가")
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                    }
                }
                
                Section("난이도 및 카테고리") {
                    Picker("난이도", selection: $selectedDifficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(QuizCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("이미지 / 동영상 추가") {
                    ForEach($selectedMediaItems) { $item in
                        mediaPreview(item: item)
                        
                        Button("삭제", role: .destructive) {
                            if let index = selectedMediaItems.firstIndex(where: { $0.id == item.id }) {
                                if let url = selectedMediaItems[index].previewURL {
                                    try? FileManager.default.removeItem(at: url)
                                }
                                selectedMediaItems.remove(at: index)
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red)
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItems,
                                 maxSelectionCount: 0,
                                 matching: .any(of: [.images, .videos])
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("사진 보관함에서 추가하기")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
                
                Section {
                    Button("저장하기") {
                        print("--------------- 퀴즈 저장 정보 ---------------")
                        print("질문: \(newQuestion.questionText)")
                        print("설명: \(newQuestion.description)")
                        print("보기 목록: \(newQuestion.answerOptions.map { ($0.text, $0.isCorrect) })")
                        print("난이도: \(selectedDifficulty)")
                        print("선택된 카테고리: \(selectedCategory)")
                                
                        if selectedMediaItems.isEmpty {
                            print("첨부된 미디어: 없음")
                        } else {
                            print("첨부된 미디어: \(selectedMediaItems.count)개")
                            for (index, media) in selectedMediaItems.enumerated() {
                                print("  - 미디어 \(index + 1): 타입 \(media.type), 데이터 \(media.data.count) 바이트")
                            }
                        }
                        print("-------------------------------------------")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .listRowInsets(EdgeInsets()) // 버튼 바깥 여백 제거
            }
            .navigationTitle("퀴즈 등록 / 편집")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedPhotoItems) { newItems in
                Task {
                    // 사진 / 영상을 고르면 비동기로 처리
                    // 기존에 선택했던 미디어를 삭제
                    for item in selectedMediaItems {
                        if let url = item.previewURL {
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                    selectedMediaItems.removeAll()
                    
                    for item in newItems {
                        guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                        if item.supportedContentTypes.first(where: { $0.conforms(to: .movie) }) != nil {
                            // 영상은 미디어타입을 video로 지정
                            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
                            try? data.write(to: tempURL)
                            let newMediaItem = MediaItem(type: .video, data: data, previewURL: tempURL)
                            selectedMediaItems.append(newMediaItem)
                        } else {
                            let newMediaItem = MediaItem(type: .image, data: data, previewURL: nil)
                            selectedMediaItems.append(newMediaItem)
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    func addAnswer() {
        newQuestion.answerOptions.append(AnswerOption())
    }
    func removeAnswer(option: AnswerOption) {
        newQuestion.answerOptions.removeAll { $0.id == option.id }
    }
    
    @ViewBuilder
    private func mediaPreview(item: MediaItem) -> some View {
        VStack {
            if item.type == .image, let uiImage = UIImage(data: item.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            } else if item.type == .video {
                if let url = item.previewURL {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(12)
                } else {
                    ProgressView()
                        .frame(height: 200)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}

#Preview {
    QuizEditorView()
}

//
//  QuizEditorView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI
import PhotosUI // PhotosPicker 사용을 위해 import
import AVKit // VideoPlayer 사용을 위해 import

enum MediaType {
    case image
    case video
}

struct QuizEditorView: View {
    @State private var question: String = ""
    
    @State private var answer: [String] = Array(repeating: "", count: 4)
    @State private var correctAnswerIndex: Set<Int> = []
    
    @State private var difficulty: [String] = ["쉬움", "보통", "어려움"]
    @State private var selectedDifficulty: String = "보통"
    
    @State private var categories: [String] = ["iOS", "Design", "CS", "직접 추가하기..."]
    @State private var selectedCategory: String = "iOS"
    @State private var newCategoryName: String = ""
    @State private var isShowingAlert: Bool = false
    
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
                Section("문제") {
                    TextField("문제를 입력하세요.", text: $question)
                        .autocorrectionDisabled()
                }
                
                Section("보기 및 정답 체크") {
                    VStack {
                        ForEach(0..<answer.count, id: \.self) { index in
                            HStack {
                                TextField("\(index + 1). 선택지를 입력하세요.", text: $answer[index])
                                    .autocorrectionDisabled()
                                    .padding(.vertical, 8)
                                Button(action: {
                                    toggleAnswerSelection(at: index)
                                }) {
                                    Image(systemName: correctAnswerIndex.contains(index) ? "checkmark.square.fill" : "square")
                                }
                                .buttonStyle(.plain)
                                
                                if answer.count > 2 {
                                    Button(action: {
                                        removeAnswer(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                        Button(action: addAnswer) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("보기 추가")
                            }
                        }
                    }
                }
                
                Section("난이도 및 카테고리") {
                    Picker("난이도", selection: $selectedDifficulty) {
                        ForEach(difficulty, id: \.self) { difficulty in
                            Text(difficulty)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedCategory) { newValue in
                        if newValue == "직접 추가하기..." {
                            self.isShowingAlert = true
                        }
                    }
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
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .listRowInsets(EdgeInsets()) // 버튼 바깥 여백 제거
            }
            .navigationTitle("퀴즈 등록")
            .navigationBarTitleDisplayMode(.inline)
            .alert("새 카테고리 추가", isPresented: $isShowingAlert) {
                TextField("카테고리 이름", text: $newCategoryName)
                Button("추가", action: addNewCategory)
                Button("취소", role: .cancel) {
                    selectedCategory = categories.first ?? "iOS"
                }
            } message: {
                Text("추가할 카테고리의 이름을 입력해주세요.")
            }
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
        }
    }
    
    func toggleAnswerSelection(at index: Int) {
        if correctAnswerIndex.contains(index) {
            correctAnswerIndex.remove(index)
        } else {
            correctAnswerIndex.insert(index)
        }
    }
    
    func addAnswer() {
        answer.append("")
    }
    func removeAnswer(at index: Int) {
        answer.remove(at: index)
        correctAnswerIndex.removeAll()
    }
    
    func addNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            return
        }
        
        categories.insert(trimmedName, at: categories.count - 1)
        selectedCategory = trimmedName
        newCategoryName = ""
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

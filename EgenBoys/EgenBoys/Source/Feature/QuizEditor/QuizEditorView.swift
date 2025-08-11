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
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedMediaData: Data?
    @State private var selectedMediaType: MediaType?
    @State private var videoPreviewURL: URL?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("문제") {
                    TextField("문제를 입력하세요.", text: $question)
                        .autocorrectionDisabled()
                }
                
                Section("보기 및 정답") {
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
                        }
                        .padding()
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
                    if let data = selectedMediaData, let type = selectedMediaType {
                        mediaPreview(data: data, type: type)
                        Button("삭제", role: .destructive) {
                            // 임시 파일 남아있으면 삭제
                            if let videoPreviewURL {
                                try? FileManager.default.removeItem(at: videoPreviewURL)
                            }
                            selectedPhotoItem = nil
                            selectedMediaData = nil
                            selectedMediaType = nil
                            videoPreviewURL = nil
                        }
                    } else {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .any(of: [.images, .videos])
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("사진 보관함에서 선택")
                            }
                            .foregroundColor(.accentColor)
                        }
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
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    // 사진 / 영상을 고르면 비동기로 처리
                    // 임시 파일 삭제
                    if let videoPreviewURL {
                        try? FileManager.default.removeItem(at: videoPreviewURL)
                        self.videoPreviewURL = nil
                    }
                    
                    guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                    if newItem?.supportedContentTypes.first(where: { $0.conforms(to: .movie) }) != nil {
                        // 영상은 미디어타입을 video로 지정
                        self.selectedMediaType = .video
                            
                        // 임시 파일 저장 로직
                        let tempDir = FileManager.default.temporaryDirectory
                        let tempURL = tempDir.appendingPathComponent("\(UUID().uuidString).mp4")
                        do {
                            try data.write(to: tempURL)
                            self.videoPreviewURL = tempURL
                        } catch {
                            print("임시 파일 저장 실패: \(error.localizedDescription)")
                        }
                    } else {
                        // 사진은 image로 지정
                        selectedMediaType = .image
                        }
                    self.selectedMediaData = data
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
    private func mediaPreview(data: Data, type: MediaType) -> some View {
        VStack {
            if type == .image, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            } else if type == .video {
                if let videoURL = videoPreviewURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
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

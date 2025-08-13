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

struct AnswerOptionRowView: View {
    @Binding var option: AnswerOption
    
    let index: Int
    let totalCount: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text("\(index + 1).")
                .foregroundColor(.gray)
            
            TextField("선택지를 입력하세요.", text: $option.text)
                .autocorrectionDisabled()
                .padding(.vertical, 5)
            
            Button(action: {
                option.isCorrect.toggle()
            }) {
                Image(systemName: option.isCorrect ? "checkmark.square.fill" : "square")
            }
            .buttonStyle(.plain)
            
            if totalCount > 2 {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        Divider()
    }
}

struct QuizEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var newQuestion = CreateQuestion()
    
    @State private var selectedDifficulty: Difficulty = .medium
    
    @State private var selectedCategory: QuizCategory = .ios
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedMediaItems: [MediaItem] = []
    
    @State private var isShowingSaveAlert = false
    
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
                        ForEach(newQuestion.answerOptions.indices, id: \.self) { index in
                            AnswerOptionRowView(
                                option: $newQuestion.answerOptions[index],
                                index: index,
                                totalCount: newQuestion.answerOptions.count,
                                onDelete: {
                                    removeAnswer(at: index)
                                }
                            )
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
                        saveQuiz()
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
        .alert("저장 완료", isPresented: $isShowingSaveAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("퀴즈가 저장되었습니다.")
        }
    }
        
    func addAnswer() {
        newQuestion.answerOptions.append(AnswerOption())
    }
    func removeAnswer(at index: Int) {
        newQuestion.answerOptions.remove(at: index)
    }
    
    private func saveQuiz() {
        let questionsForSwiftData: [Question] = newQuestion.answerOptions.map { option in
            return Question(content: option.text, isCorrect: option.isCorrect)
        }
        let (imageURL, videoURL) = saveMediaFiles()
        
        let newQuizForSwiftData = Quiz(
            title: newQuestion.questionText,
            explanation: newQuestion.description,
            category: selectedCategory,
            questions: questionsForSwiftData,
            imageURL: imageURL,
            videoURL: videoURL,
            difficultty: selectedDifficulty
        )
        
        modelContext.insert(newQuizForSwiftData)
        do {
            try modelContext.save()
            print("퀴즈 저장 완료.")
            isShowingSaveAlert = true
        } catch {
            print("퀴즈 저장 실패: \(error)")
        }
    }
    private func saveMediaFiles() -> (imageURL: URL?, videoURL: URL?) {
        var savedImageURL: URL?
        var savedVideoURL: URL?
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return (nil, nil)
        }
        
        for mediaItem in selectedMediaItems {
            let fileExtension = (mediaItem.type == .image) ? "jpg" : "mp4"
            let fileName = "\(UUID().uuidString).\(fileExtension)"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                try mediaItem.data.write(to: fileURL)
                
                if mediaItem.type == .image {
                    savedImageURL = fileURL
                } else {
                    savedVideoURL = fileURL
                }
            } catch {
                print("미디어 저장 실패: \(error)")
            }
        }
        return (savedImageURL, savedVideoURL)
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

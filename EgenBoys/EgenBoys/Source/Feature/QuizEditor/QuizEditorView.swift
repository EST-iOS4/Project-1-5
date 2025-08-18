//
//  QuizEditorView.swift
//  EgenBoys
//
//  Created by 구현모 on 8/13/25.
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
        HStack(alignment: .center) {
            Text("\(index + 1).")
                .foregroundColor(.gray)
                .withCustomFont()
            
            TextField("선택지를 입력하세요.", text: $option.text)
                .autocorrectionDisabled()
                .padding(.vertical, 10)
                .withCustomFont()
            
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
        Divider()
    }
}

struct QuizEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var quizToEdit: Quiz?
    
    @State private var newQuestion = CreateQuestion()
    
    @State private var selectedDifficulty: Difficulty = .medium
    
    @State private var selectedCategory: QuizCategory = .ios
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedMediaItems: [MediaItem] = []
    
    @State private var isShowingSaveAlert = false
    
    private var isSaveButtonDisabled: Bool {
        let isQuestionEmpty = newQuestion.questionText.trimmingCharacters(in: .whitespaces).isEmpty
        let areAnyOptionsEmpty = newQuestion.answerOptions.contains { option in option.text.trimmingCharacters(in: .whitespaces).isEmpty
        }
        let isNoAnswerChecked = !newQuestion.answerOptions.contains { $0.isCorrect }
        return isQuestionEmpty || areAnyOptionsEmpty || isNoAnswerChecked
    }
    
    struct MediaItem: Identifiable {
        let id = UUID()
        let type: MediaType
        let data: Data
        var previewURL: URL?
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack {
                        TextField("문제를 입력하세요.", text: $newQuestion.questionText, axis: .vertical)
                            .autocorrectionDisabled()
                            .padding(.vertical, 8)
                            .withCustomFont()
                        Divider()
                        TextField("문제에 대한 설명을 입력하세요.", text: $newQuestion.description, axis: .vertical)
                            .autocorrectionDisabled()
                            .padding(.vertical, 8)
                            .withCustomFont()
                    }
                } header: {
                    Text("문제 및 설명")
                        .padding(.leading, -12)
                }
                
                Section {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                            Text("정답으로 사용할 보기를 체크해주세요.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .withCustomFont()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
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
                                    .withCustomFont()
                            }
                        }
                        .padding(.vertical, 8)
                        .buttonStyle(.plain)
                        .foregroundColor(.blue)
                    }
                } header: {
                    Text("보기 및 정답")
                        .padding(.leading, -8)
                }
                .listRowInsets(EdgeInsets(top: .zero, leading: 15, bottom: .zero, trailing: 15))

                Section {
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
                } header: {
                    Text("난이도 및 카테고리")
                        .padding(.leading, -12)
                }
                
                Section {
                    ForEach($selectedMediaItems) { $item in
                        HStack {
                            mediaPreview(item: item)
                                .buttonStyle(.plain)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItems,
                                 maxSelectionCount: 0,
                                 matching: .any(of: [.images, .videos])
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("사진 보관함에서 추가하기")
                                .withCustomFont()
                        }
                        .foregroundColor(.accentColor)
                    }
                } header: {
                    Text("이미지 / 동영상 추가")
                        .padding(.leading, -12)
                }
                
                Section {
                    Button("저장하기") {
                        saveQuiz()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(isSaveButtonDisabled ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(isSaveButtonDisabled)
                }
                .listRowInsets(EdgeInsets()) // 버튼 바깥 여백 제거
            }
            .navigationTitle("퀴즈 등록 / 편집")
            .onAppear(perform: setupForEditing)
            .navigationBarTitleDisplayMode(.large)
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
                resetInputs()
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
        
        if let quiz = quizToEdit {
            quiz.title = newQuestion.questionText
            quiz.explanation = newQuestion.description
            quiz.category = selectedCategory
            quiz.questions = questionsForSwiftData
            quiz.difficultty = selectedDifficulty
            
            if let imageURL { quiz.imageURL = imageURL }
            if let videoURL { quiz.videoURL = videoURL }
        } else {
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
        }
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
    private func resetInputs() {
        newQuestion = CreateQuestion()
        
        selectedDifficulty = .medium
        selectedCategory = .ios
        selectedPhotoItems = []
        selectedMediaItems = []
    }
    private func setupForEditing() {
        guard let quiz = quizToEdit else { return }
        
        newQuestion.questionText = quiz.title
        newQuestion.description = quiz.explanation
        newQuestion.answerOptions = quiz.questions.map { question in
            AnswerOption(text: question.content, isCorrect: question.isCorrect)
        }
        selectedDifficulty = quiz.difficultty
        selectedCategory = quiz.category
        
        selectedMediaItems.removeAll()
        
        Task {
            if let imageURL = quiz.imageURL {
                do {
                    let imageData = try Data(contentsOf: imageURL)
                    let imageItem = MediaItem(type: .image, data: imageData)
                    await MainActor.run { selectedMediaItems.append(imageItem) }
                } catch {
                    print("저장된 이미지 파일 로드 실패: \(error)")
                }
            }
            
            if let videoURL = quiz.videoURL {
                do {
                    let videoData = try Data(contentsOf: videoURL)
                    let videoItem = MediaItem(type: .video, data: videoData, previewURL: videoURL)
                    await MainActor.run { selectedMediaItems.append(videoItem) }
                } catch {
                    print("저장된 비디오 파일 로드 실패: \(error)")
                }
            }
        }
    }
    
    @ViewBuilder
    private func mediaPreview(item: MediaItem) -> some View {
        if item.type == .image, let uiImage = UIImage(data: item.data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topTrailing) {
                    deleteButton(for: item)
                        .offset(x: 14, y: -14)
                }
        } else if item.type == .video {
            if let url = item.previewURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(alignment: .topTrailing) {
                        deleteButton(for: item)
                            .offset(x: 14, y: -14)
                    }
            } else {
                ProgressView()
                    .frame(height: 200)
            }
        }
    }

    private func deleteButton(for item: MediaItem) -> some View {
        Button(action: {
            if let index = selectedMediaItems.firstIndex(where: { $0.id == item.id }) {
                if let url = selectedMediaItems[index].previewURL {
                    try? FileManager.default.removeItem(at: url)
                }
                selectedMediaItems.remove(at: index)
            }
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.red)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }

}

#Preview {
    QuizEditorView()
}

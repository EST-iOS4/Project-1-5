//
//  CacheManager.swift
//  EgenBoys
//
//  Created by 이건준 on 8/13/25.
//

import SwiftUI

@MainActor
final class CacheManager: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private static let cache = NSCache<NSString, UIImage>()
    private var cancellable: Task<Void, Never>?
    
    func load(from urlString: String) {
        load(from: URL(string: urlString))
    }
    
    func load(from url: URL?) {
        guard let url = url else { return }
        
        let urlString = url.absoluteString
        
        if let cachedImage = Self.cache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        cancellable?.cancel()
        
        cancellable = Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            defer { self.isLoading = false }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard !Task.isCancelled else { return }
                
                if let downloadedImage = UIImage(data: data) {
                    Self.cache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            } catch {
                print("이미지 다운로드 실패: \(error)")
                self.image = nil
            }
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

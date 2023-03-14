//
//  AppGCD - LusterView.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

enum ImageURL {
    private static let imageIds: [String] = [
        "europe-4k-1369012",
        "europe-4k-1318341",
        "europe-4k-1379801",
        "cool-lion-167408",
        "iron-man-323408"
    ]
    
    static var allURLS: [URL] {
        return Self.imageIds.map {
            URL(string: "https://wallpaperaccess.com/download/"+$0)!
        }
    }
    
    static subscript(index: Int) -> URL {
        let id = imageIds[index]
        return URL(string: "https://wallpaperaccess.com/download/"+id)!
    }
}

extension UIImage {
    func resizedImage(ofSize: CGSize) -> UIImage {
        return self
    }
    var thumbnail: UIImage {
        get async {
            let size = CGSize(width: 50, height: 50)
            return self.resizedImage(ofSize: size)
        }
    }
}

final class LusterView: UIView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var loadButton: UIButton!
    private var imageLoadTask: Task<Void, Error>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadButton.setTitle("Stop", for: .selected)
        loadButton.setTitle("Load", for: .normal)
        loadButton.isSelected = false
    }
    
    deinit {
        
    }
    
    func reset() {
        self.imageView.image = .init(systemName: "photo")
        self.progressView.progress = 0
        self.loadButton.isSelected = false
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func fetchImage(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        if imageLoadTask.isCancelled { return UIImage(systemName: "xmark")! }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
              (200...299).contains(statusCode) else { throw NSError(domain: "fetch error", code: 1004) }
        if imageLoadTask.isCancelled { return UIImage(systemName: "xmark")! }
        guard let image = UIImage(data: data) else { throw NSError(domain: "image coverting error", code: 999)}
        return image
    }

    func startLoad(url: URL) {
        imageLoadTask = Task {
            let image = try await imageFetcher.fetchImage(url: url as NSURL)
            guard imageLoadTask.isCancelled == false else {
                reset()
                return
            }
            imageView.image = image
        }
    }
    
    @IBAction private func touchUpLoadButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            self.imageLoadTask?.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("버튼 태그를 확인해주세요")
        }
        
        startLoad(url: ImageURL[sender.tag])
    }
}

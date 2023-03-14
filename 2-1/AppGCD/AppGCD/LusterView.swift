//
//  AppGCD - LusterView.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

fileprivate enum ImageURL {
    private static let imageIds: [String] = [
        "europe-4k-1369012",
        "europe-4k-1318341",
        "europe-4k-1379801",
        "cool-lion-167408",
        "iron-man-323408"
    ]
    
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
    private var observation: NSKeyValueObservation!
    private var task: URLSessionDataTask!
    private var workItem: BlockOperation!
    private var imageLoadTask: Task<Void, Error>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadButton.setTitle("Stop", for: .selected)
        loadButton.setTitle("Load", for: .normal)
        loadButton.isSelected = false
    }
    
    deinit {
        observation?.invalidate()
        observation = nil
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.imageView.image = .init(systemName: "photo")
            self.progressView.progress = 0
            self.loadButton.isSelected = false
        }
    }
    
    func loadImage() {
        loadButton.sendActions(for: .touchUpInside)
    }
    
    func stopLoading() {
        
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
    
    func fetchThumbnail(url: URL) async throws -> UIImage {
        let image = try await fetchImage(url: url)
        return await image.thumbnail
    }
    
    private func startLoad(url: URL) {
        
//        Task.detached {
//            let image: UIImage = try await self.fetchImage(url: url)
//            await MainActor.run {
//                self.imageView.image = image
//            }
//        }
        
        imageLoadTask = Task(priority: .userInitiated) {
            let image: UIImage = try await fetchImage(url: url)
            imageView.image = image
        }
        
        /*
        workItem = BlockOperation {
            guard self.workItem.isCancelled == false else {
                self.reset()
                return
            }
            
            let request = URLRequest(url: url)
            
            self.task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    guard error.localizedDescription == "cancelled" else {
                        fatalError(error.localizedDescription)
                    }
                    OperationQueue.main.addOperation {
                        self.reset()
                    }
                    return
                }
                
                guard self.workItem.isCancelled == false else {
                    self.reset()
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    OperationQueue.main.addOperation {
                        self.imageView.image = .init(systemName: "xmark")
                    }
                    return
                }
                
                guard self.workItem.isCancelled == false else {
                    self.reset()
                    return
                }
                
                OperationQueue.main.addOperation {
                    self.imageView.image = image
                    self.loadButton.isSelected = false
                }
            }
            
            self.observation = self.task.progress.observe(\.fractionCompleted,
                                                 options: [.new],
                                                 changeHandler: { progress, change in
                OperationQueue.main.addOperation {
                    guard self.workItem.isCancelled == false else {
                        self.observation.invalidate()
                        self.observation = nil
                        self.progressView.progress = 0
                        return
                    }
                    self.progressView.progress = Float(progress.fractionCompleted)
                }
            })
            
            self.task.resume()
        }
        
        OperationQueue().addOperation(workItem)
         */
    }
    
    @IBAction private func touchUpLoadButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            self.imageLoadTask.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("버튼 태그를 확인해주세요")
        }
        
        let url = ImageURL[sender.tag]
        startLoad(url: url)
        
        /*
        guard sender.isSelected else {
            self.workItem.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("버튼 태그를 확인해주세요")
        }
        let url = ImageURL[sender.tag]
        startLoad(url: url)
         */
    }
}

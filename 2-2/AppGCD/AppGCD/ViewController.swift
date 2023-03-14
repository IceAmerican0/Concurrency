//
//  AppGCD - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit


actor ImageFetcher {
    private var images: NSCache<NSURL, UIImage> = NSCache()
    
    private subscript(url: NSURL) -> UIImage? {
        return images.object(forKey: url)
    }
    
    func fetchImage(url: NSURL) async throws -> UIImage {
        if let image = self[url] {
            return image
        }
        let (data, _) = try await URLSession.shared.data(from: (url as URL))
        let image = UIImage(data: data)!
        images.setObject(image, forKey: url)
        return image
    }
}

class ImageIterator: AsyncIteratorProtocol {
    private var index: Int = 0
    func next() async throws -> UIImage? {
        defer { index += 1 }
        guard index < 5 else { return nil }
        let url = ImageURL[index]
        return try await imageFetcher.fetchImage(url: url as NSURL)
    }
    
    typealias Element = UIImage
}

class ImageSequence: AsyncSequence {
    func makeAsyncIterator() -> ImageIterator {
        return ImageIterator()
    }
    
    typealias AsyncIterator = ImageIterator
    typealias Element = UIImage
}

let imageSequence = ImageSequence()
let imageFetcher = ImageFetcher()


final class ViewController: UIViewController {

    @IBOutlet private var views: [LusterView]!
    @IBOutlet private var loadButton: UIButton!
    private var loadAllImageTask: Task<Void, Error>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        views.forEach { $0.reset() }
        
        loadButton?.setTitle("Load All Images", for: .normal)
        loadButton?.setTitle("Stop All Images", for: .selected)
        loadButton?.setTitleColor(.yellow, for: .normal)
        loadButton?.setTitleColor(.red, for: .selected)
    }
    
    @IBAction private func touchUpLoadAllImageButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            self.loadAllImageTask?.cancel()
            views.forEach { $0.reset() }
            return
        }
        
        loadAllImageTask = Task {
            zip(views, ImageURL.allURLS).forEach { (view, url) in
                view.startLoad(url: url)
            }
            var index = 0
            for try await image in imageSequence {
                guard loadAllImageTask.isCancelled == false else {
                    break
                }
                defer { index += 1 }
                views[index].setImage(image)
                print(index)
            }
        }
        
    }
}


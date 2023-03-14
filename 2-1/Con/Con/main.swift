//
//  Con - main.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import Foundation


var heesang: Int = 0
let group = DispatchGroup()

let start = CFAbsoluteTimeGetCurrent()

for i in 1...1000000 {
    group.enter()
    DispatchQueue.global().async {
        heesang = i
        group.leave()
    }
    group.wait()
}
print(heesang)
let end = CFAbsoluteTimeGetCurrent()
print(end - start)
 
/*
let start = CFAbsoluteTimeGetCurrent()

let semaphore = DispatchSemaphore(value: 0)
for i in 1...1000000 {
    DispatchQueue.global().async {
        heesang = i
        semaphore.signal()
    }
    semaphore.wait()
}
print(heesang)
let end = CFAbsoluteTimeGetCurrent()
print(end - start)
*/
/*
let semaphore = DispatchSemaphore(value: 0)
let serialQueue = DispatchQueue(label: "serial")
let serialQueue2 = DispatchQueue(label: "serial2")

for i in 1...10000 {
//    DispatchQueue.global().async {
    serialQueue.async {
        heesang = i
        semaphore.signal()
    }
    semaphore.wait()
    serialQueue2.async {
        heesang = i + 787878
        semaphore.signal()
    }
    semaphore.wait()
//        semaphore.signal()
//    }
//    semaphore.wait()
}

print(heesang)
*/

/*
let myQueue = DispatchQueue(label: "myQueue", qos: .userInitiated, attributes: .concurrent)
let imageDownloadQueue = DispatchQueue(label: "download", qos: .background, attributes: .concurrent)

func printSomething() {
    for name in ["야곰 🥰", "명진", "현이 🌈", "러스터 🥕", "갱이", "제니"] {
        print(name)
    }
}

func downloadImage() {
    for _ in 0...5 {
        print("이미지이미지")
    }
}

let dispatchItem = DispatchWorkItem {
    printSomething()
}

let dispatchItem2 = DispatchWorkItem {
    downloadImage()
}


class NameOperation: Operation {
    override func main() {

        printSomething()
    }
}

class ImageOperation: Operation {
    override func main() {
        guard self.isCancelled == false else {
            return
        }
        downloadImage()
    }
}
//
//for _ in (0...300) {
//    imageDownloadQueue.async(execute: dispatchItem2)
//    myQueue.async(execute: dispatchItem)
//}
let nameQueue = OperationQueue()
nameQueue.qualityOfService = .background
//nameQueue.maxConcurrentOperationCount = 1
let imageQueue = OperationQueue()
imageQueue.qualityOfService = .userInteractive
//imageQueue.maxConcurrentOperationCount = 1

for _ in (0...300) {
    nameQueue.addOperation(NameOperation())
    imageQueue.addOperation(ImageOperation())
}

Thread.sleep(forTimeInterval: 0.001)

//nameQueue.cancelAllOperations()
//nameQueue.operations.forEach {$0.cancel()}

sleep(10)
*/

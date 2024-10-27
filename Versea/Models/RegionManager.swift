//
//  RegionManager.swift
//  Versea
//
//  Created by Hazel Gong on 2024/10/10.
//

import Foundation
import SwiftUI

class RegionManager: ObservableObject {
    static let shared = RegionManager()
    @Published var allBlocks: [String: [Block]] = [:]
    var initWordIdex: Int = -1  // 第一个单词的索引
    var timer: Timer? // 跟踪定时器的引用

    
    init() {
        let images = generateImagesConcurrently(count: 32)
        if images.count > 0 {
            for x in 0..<3 {
                for y in 0..<3 {
                    var blocks: [Block] = []
                    for j in 0..<8 {
                        for k in 0..<4 {
                            let position = (x: j, y: k)
                            let randomColor = Color.randomCustomColor()
                            let id = "\(x)\(y)-\(j)\(k)"
                            let page_index = "\(x)-\(y)"
                            let randomIndex = Int(arc4random_uniform(UInt32(images.count)))
                            let newBlock = Block(id: id, page_index: page_index, position: position,
                                                 backgroundColor: randomColor, noiseImage: images[randomIndex] ?? UIImage())
                            blocks.append(newBlock)
                        }
                    }
                    allBlocks["\(x)-\(y)"] = blocks
                }
            }
        }
    }
    
    // 生成初始索引
    func generateFirstBlockWord(page_index: String = "0-0", count: Int = 1) {
        if self.initWordIdex == -1 {
            // 第一页的数据随机生成一个单词
             let word = generateRandomWord()
             self.initWordIdex = Int(arc4random_uniform(UInt32(11))) + 10
             allBlocks[page_index]?[self.initWordIdex ].text = word
             allBlocks[page_index]?[self.initWordIdex ].backgroundColor = Color.randomCustomColor()
             allBlocks = allBlocks // 重新赋值字典
            
             // 生成额外五个
            generateBlockWordRandom()
        }
     }

    
    // 生成块
    func generateBlockWord(page_index: String = "0-0", count: Int = 5) {
        let excludedIndex: Int? = self.initWordIdex
        // 确保字典中有 "0-0" 键，并且对应的数组至少有 count 个元素
        if allBlocks[page_index]?.count ?? 0 >= count {
            // 随机生成五个不同的索引
            let allIndices = Array(0..<allBlocks.count-1)
            // 如果提供了 excludedIndex，则从所有索引中排除它
           let filteredIndices = excludedIndex.map { exclude in
               allIndices.filter { $0 != exclude }
           } ?? allIndices
            let randomIndices = filteredIndices.shuffled().prefix(count)
            for index in randomIndices {
                // 为每个索引生成一个新的单词和颜色
                let word = generateRandomWord()
                let color = Color.randomCustomColor()
                // 更新对应索引的单词和颜色
                allBlocks[page_index]![index].text = word
                allBlocks[page_index]![index].backgroundColor = color
            }
            allBlocks = allBlocks // 重新赋值字典
        }
    }
    
    
    // 生成不包含初始位置的块
    func generateBlockWordRandom(page_index: String = "0-0", count: Int = 5) {
        let excludedIndex: Int? = self.initWordIdex
        // 确保字典中有 "0-0" 键，并且对应的数组至少有 count 个元素
        if allBlocks[page_index]?.count ?? 0 >= count {
            // 随机生成五个不同的索引
            let allIndices = Array(self.initWordIdex-10..<32-10)
            // 如果提供了 excludedIndex，则从所有索引中排除它
           let filteredIndices = excludedIndex.map { exclude in
               allIndices.filter { $0 != exclude }
           } ?? allIndices
            let randomIndices = filteredIndices.shuffled().prefix(count)
            for index in randomIndices {
                // 为每个索引生成一个新的单词和颜色
                let word = generateRandomWord()
                let color = Color.randomCustomColor()
                // 更新对应索引的单词和颜色
                allBlocks[page_index]![index].text = word
                allBlocks[page_index]![index].backgroundColor = color
            }
            allBlocks = allBlocks // 重新赋值字典
        }
    }
    
    
    // 异步随机生成
    func generateImagesConcurrently(count: Int) -> [UIImage?] {
        let dispatchGroup = DispatchGroup()
        var generatedImages = [UIImage?]()
        
        for _ in 0..<count {
            dispatchGroup.enter()
            DispatchQueue.global(qos:.userInitiated).async {
                if let image = generateNoiseImage() {
                    generatedImages.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        return generatedImages
    }

    func update(for page_index: String, blockID: String, newWord: String, newColor: Color) {
        if let blockArray = allBlocks[page_index] {
            for blockObject in blockArray {
                if blockObject.id == blockID {
                    blockObject.backgroundColor = newColor
                    blockObject.text = newWord
                    break
                }
            }
            allBlocks[page_index] = blockArray // 更新数组
        }
        allBlocks = allBlocks // 重新赋值字典
    }
    
    func startAutoFlashing() {
            // 如果定时器已经存在，不再创建新的定时器
            if timer != nil {
                return
            }

            // 每 3 秒触发一次定时器
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }

                // 遍历所有页面的方块
                for (_, blocks) in self.allBlocks {
                    for block in blocks {
                        if block.isFlashing == true {
                            // 随机生成新的文字和颜色
                            let randomWord: String
                            if arc4random_uniform(3) == 1 {
                                randomWord = self.generateRandomWord()
                            } else {
                                randomWord = ""
                            }
                            
                            let randomColor = Color.randomCustomColor()

                            // 更新方块的文字和背景颜色
                            self.update(for: block.page_index, blockID: block.id, newWord: randomWord, newColor: randomColor)
                        }
                    }
                }
            }
        }
    
    
    // 非异步版本，直接从缓存中获取一个随机单词
    func generateRandomWord() -> String {
        // 从已缓存的词库中选取一个随机单词
        let randomWord = WordManager.shared.wordList.randomElement() ?? ""
        return randomWord
    }
    
    func reorderCurrentPage() {
        
    }

    
    
    
}

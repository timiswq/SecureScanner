//
//  Services+ImageAI.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/3/6.
//  Copyright © 2025 Tim. All rights reserved.
//

import Vision
import SwiftUI
import MKCoreTypes
import NaturalLanguage

actor ImageAI{
    func ocrImage(image: UIImage) async throws -> String{
        var content = ""
        guard let imageData = image.pngData() else{
            throw MOError("图像数据为空，无法分析")
        }
        var recognizer = RecognizeTextRequest()
        recognizer.automaticallyDetectsLanguage = true
        recognizer.recognitionLevel = .accurate
        let res = try await recognizer.perform(on: imageData)
        var pHeight: CGFloat = 0
        var pArea: CGFloat = 0
        
        for obs in res{
            if let top1 = obs.topCandidates(1).first {
                let str = top1.string
                MOLog("命中词：\(str),（\(top1.confidence)）")
                ///计算区域面积，以面积最大的区域作为文件标题
                let height = obs.boundingBox.height
                let area = obs.boundingBox.width * height
                if top1.confidence > 0.2,
                    ///高度超过原高度的1.2倍 ,且面积比原来的要大，则认为是重要的文字
                   (height / pHeight) > 1.5, area > pArea{
                    
                    content = strippingNonContentCharacters(str: str)
                    pArea  = area
                    pHeight = height
                }
            }
        }
        return content
    }
    /// 去除所有非内容字符（保留字母、数字、中日韩文字及常用符号）
    private func strippingNonContentCharacters(str: String) -> String{
        let tagger = NLTagger(tagSchemes: [.nameType])
        var words: [String] = []
        tagger.string = str
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        tagger.enumerateTags(in: str.startIndex..<str.endIndex,
                             unit: .word,
                             scheme: .nameType,
                             options: options)
        { tag, tokenRange in
            if let tag = tag{
                let txt = String(str[tokenRange])
                print("\(txt)，是\(tag.rawValue)")
                words.append(txt)
            }
            return true
        }
                         
        return words.joined()
    }
}

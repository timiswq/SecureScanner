//
//  CGSize+Extensions.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/26.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI

extension CGSize{
    ///自适应比例缩放
    func aspectFit(_ to: CGSize) -> CGSize{
        let scaleX = to.width / width
        let scaleY = to.height / height
        
        let aspectRatio = min(scaleX, scaleY)
        
        return .init(width: aspectRatio * width, height: aspectRatio * height)
    }
}

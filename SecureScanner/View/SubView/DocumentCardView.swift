//
//  DocumentCardView.swift
//  SecureScanner
//
//  Created by Qing Wang on 2025/2/26.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI

struct DocumentCardView: View {
    var document: Document
    var animationID: Namespace.ID
    
    @State private var downsizedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            if let firstpage = document.pages?.sorted(by: {$0.pageIndex < $1.pageIndex}).first{
                GeometryReader { geo in
                    let size = geo.size
                    
                    if let downsizedImage{
                        Image(uiImage: downsizedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                    }else{
                        Rectangle()
                            .foregroundStyle(.clear)
                            .task(priority: .high) {
                                guard let image = UIImage(data: firstpage.pageData) else {
                                    return
                                }
                                let aspectSize = image.size.aspectFit(.init(width: 150, height: 150))
                                let renderer = UIGraphicsImageRenderer(size: aspectSize)
                                let resizedImage = renderer.image { context in
                                    image.draw(in: .init(origin: .zero, size: aspectSize))
                                }
                                
                                await MainActor.run {
                                    downsizedImage = resizedImage
                                }
                            }
                    }
                    
                    if document.isLocked{
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                            
                            Image(systemName: "lock.fill")
                                .font(.title3)
                        }
                    }
                }
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 15))
                .matchedTransitionSource(id: document.uniqueViewID, in: animationID)
                .shadow(color: .primary.opacity(0.4), radius: 4, x: 1, y: 0)
            }
            
            Text(document.name)
                .font(.callout)
                .lineLimit(1)
                .padding(.top, 10)
            
            Text("\(document.created.formatted(date: .numeric, time: .shortened))(\(document.pages?.count ?? -1))")
                .font(.caption2)
                .foregroundStyle(.gray)
        }
    }
}

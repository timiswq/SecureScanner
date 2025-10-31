//
//  Home.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/26.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI
import SwiftData
import MKCoreTypes
import MKCommonUI
import VisionKit

struct Home: View {
    @Environment(\.modelContext) var context
    
    @Namespace private var animationID
    
    @State private var showScannerView: Bool = false
    @State private var documentName: String = "新的扫描件\(Date.now.formatDate4FileName())"
    @State private var askDocumentName: Bool = false
    @State private var scanDocument: VNDocumentCameraScan?
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @Query(sort: [.init(\Document.created, order: .reverse)], animation: .snappy(duration: 0.25, extraBounce: 0)) private var documents: [Document]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: 2)) {
                    ForEach(documents) { doc in
                        NavigationLink {
                            DocumentDetial(document: doc)
                                .navigationTransition(.zoom(sourceID: doc.uniqueViewID, in: animationID))
                        } label: {
                            DocumentCardView(document: doc, animationID: animationID)
                                .foregroundStyle(Color.primary)

                        }
                    }
                }
                .padding(15)
            }
            .navigationTitle("文件(\(documents.count))")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if documents.count == 0{
                    VStack {
                        Interactions(effect: .none, cPosition: .init(x: 0, y: 47)){ screenSize, showTouch, animates in
                            Rectangle()
                                .fill(.fill)
                                .frame(width: 80, height: 120)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.fill)
                                .frame(width: animates ? 15 : 80, height:animates ? 15 : 120)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .offset(x: animates ? -33 : 0, y: animates ? 74 : 0)
                                .opacity(showTouch ? 1 : 0)
                            
                            Circle()
                                .fill(.fill)
                                .frame(width: 15, height: 15)
                                .overlay(content: {
                                    Circle()
                                        .stroke(.background)
                                        .fill(.fill)
                                        .frame(width: 10, height: 10)
                                })
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .offset(y: 75)
                        }
                        .opacity(0.5)
                    }
                    .vSpacing(.bottom)
                }
            }
            .safeAreaInset(edge: .bottom) {
                CreateButton()
            }
        }
        .fullScreenCover(isPresented: $showScannerView) {
            ScannerView { error in
                
            } didCancel: {
                showScannerView = false
            } didFinish: { scan in
                scanDocument = scan
                Task(priority: .high) {
                    MOLog("扫描的页数\(scan.pageCount)")
                    let imageAI = ImageAI()
                    let image = scan.imageOfPage(at: 0)
                    
                    let ocrTitle = try await imageAI.ocrImage(image: image)
                    MOLog("OCR 标题：\(ocrTitle)")

                    if ocrTitle.count > 0{
                        documentName = ocrTitle
                    }else{
                        let dateStr = Date.now.formatDate4FileName()
                        documentName = "新的扫描件\(dateStr)"
                    }
                    
                    showScannerView = false
                    askDocumentName = true
                }

            }
            .ignoresSafeArea()
        }
        .alert(isPresented: $askDocumentName, content: {
            CustomDialogView(
                title: "文件名",
                content: "默认自动识别首页标题",
                image: .init(content: "folder.fill.badge.plus", tint: .blue, foreground: .white),
                button1: .init(content: "保存", tint: .blue, foreground: .white, action: { filename in
                    MOLog("文件名:\(filename)")
                    documentName = filename
                    askDocumentName = false
                    createDocument()
                }),
                button2: .init(content: "取消", tint: Color.markonceRed, foreground: .white, action: { _ in
                    askDocumentName = false
                }),
                addsTextField: true,
                textFieldHint: "文件名",
                text: $documentName,
                btn1Disabled: documentName.isEmpty
            )
            .transition(.blurReplace.combined(with: .push(from: .bottom)))
        }, background: {
            Rectangle()
                .fill(.primary.opacity(0.35)  )
        })
        .loadingScreen(status: $isLoading)
    }
    
    @ViewBuilder
    private func CreateButton() -> some View{
        Button {
            showScannerView.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "document.viewfinder.fill")
                    .font(.title3)
                
                Text("扫描新文档")
            }
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.markonceRed.gradient, in: .capsule)
            
        }
        .hSpacing(.center)
        .padding(.vertical, 10)
        .background {
            Rectangle()
                .fill(.background)
                .mask {
                    Rectangle()
                        .fill(.linearGradient(colors: [
                            .white.opacity(0),
                            .white.opacity(0.5),
                            .white,
                            .white
                        ], startPoint: .top, endPoint: .bottom))
                }
                .ignoresSafeArea()
        }

    }
    
    private func createDocument(){
        guard let scanDocument else{
            return
        }
        
        isLoading = true
        
        Task {[documentName] in
            await MainActor.run {
                let document = Document(name: documentName)
                var pages: [DocumentPage] = []
                
                for pageIndex in 0..<scanDocument.pageCount {
                    let pageImage = scanDocument.imageOfPage(at: pageIndex)
                    
                    guard let pageData = pageImage.jpegData(compressionQuality: 0.8) else {
                        return
                    }
                    let documentPage = DocumentPage(document: document, pageIndex: pageIndex, pageData: pageData)
                    pages.append(documentPage)
                }
                
                document.pages = pages
                context.insert(document)
                try? context.save()
                ///初始化数据
                self.scanDocument = nil
                self.isLoading = false
                self.documentName = "新的扫描件\(Date.now.description(with: .current))"
            }
        }
    }
}

#Preview {
    ContentView()
}

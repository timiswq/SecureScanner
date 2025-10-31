//
//  DocumentDetial.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/26.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI
import SwiftData
import PDFKit
import LocalAuthentication
import MKCoreTypes
import Photos
import MKCommonUI

struct DocumentDetial: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scene
    var document: Document
    
    @State private var isLoading: Bool = false
    @State private var showFileMover: Bool = false
    @State private var fileURL: URL?
    
    @State private var isLockAvailable: Bool?
    @State private var isUnlocked: Bool = false
    
    @State private var documentName: String = ""
    @State private var askDocumentName: Bool = false

    @State private var currentTabIndex: Int = 0
    @State var toasts: [ToastVM] = []
    var body: some View {
        if let pages = document.pages?.sorted(by: {$0.pageIndex < $1.pageIndex}){
            VStack(spacing: 10) {
                HeaderView()
                    .padding([.horizontal, .top], 15)
                TabView(selection: $currentTabIndex) {
                    ForEach(pages) { page in
                        if let image = UIImage(data: page.pageData){
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .tag(page.pageIndex)
                                .contextMenu {
                                    Button {
                                        MOLog("保存到相册")
                                        saveImageToAlbum(uiImage: image)
                                    } label: {
                                        Label("保存到照片", systemImage: "rectangle.stack.badge.plus")
                                    }
                                    Button {
                                        MOLog("分享图片")
                                        shareSingleImage(uiImage: image)
                                    } label: {
                                        Label("分享图片", systemImage: "square.and.arrow.up")
                                    }
                                } preview: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                        }
                    }
                }
                .tabViewStyle(.page)
                .interactiveToasts($toasts)
                FooterView()
                    .padding([.horizontal, .bottom], 25)
            }
            .background(.black)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .loadingScreen(status: $isLoading)
            .overlay(content: {
                lockedView()
            })
            .onAppear {
                self.documentName = document.name
                guard document.isLocked else {
                    isUnlocked = true
                    return
                }
                
                let context = LAContext()
                isLockAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                
            }
            .onChange(of: scene) { oldValue, newValue in
                if newValue != .active, document.isLocked{
                    isUnlocked = false
                }
            }
            .alert(isPresented: $askDocumentName, content: {
                CustomDialogView(
                    title: "修改文件名",
                    content: nil,
                    image: .init(content: "folder.fill.badge.plus", tint: .blue, foreground: .white),
                    button1: .init(content: "保存", tint: .blue, foreground: .white, action: { filename in
                        MOLog("文件名:\(filename)")
                        document.name = documentName
                        try? modelContext.save()
                        askDocumentName = false
                    }),
                    button2: .init(content: "取消", tint: Color.markonceRed, foreground: .white, action: { _ in
                        self.documentName = document.name
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
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View{
        Text("\(document.name)(\(currentTabIndex + 1)/\(document.pages?.count ?? 1))")
            .font(.callout)
            .foregroundStyle(.white)
            .onTapGesture {
                askDocumentName.toggle()
            }
            .hSpacing(.center)
            .overlay(alignment: .trailing) {
                Button {
                    document.isLocked.toggle()
                    isUnlocked = !document.isLocked
                    try? modelContext.save()
                } label: {
                    Image(systemName: document.isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.title3)
                        .foregroundStyle(Color.markonceRed)
                        .padding(8)
                        .background(.white.gradient, in: .circle)
                }

            }
    }
    
    @ViewBuilder
    private func FooterView() -> some View{
        HStack {
            Button {
                createAndShareDocument()
            } label: {
                Image(systemName: "document.on.document")
                //Text("\(document.pages?.count ?? 0)")
                    .font(.title3)
                    .foregroundStyle((document.pages?.count ?? 0 > 1) ? Color.markonceRed : .gray)
                    .padding(8)
                    .background(.white.gradient, in: .circle)
                    .overlay(alignment: .bottomLeading) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundStyle((document.pages?.count ?? 0 > 1) ? Color.markonceRed : .gray)
                            .padding(2)
                            .background(.white.gradient, in: .circle)
                    }
            }
            .disabled(!(document.pages?.count ?? 0 > 1))
            
            Spacer(minLength: 0)
            
            Button {
                dismiss()
                Task { @MainActor in
                    ///用来给特效播放的时间
                    try? await Task.sleep(for: .seconds(0.3))
                    modelContext.delete(document)
                    try? modelContext.save()
                }
            } label: {
                Image(systemName: "trash.fill")
                    .font(.title3)
                    .foregroundStyle(Color.markonceRed)
                    .padding(8)
                    .background(.white.gradient, in: .circle)
            }


        }
    }
    
    @ViewBuilder
    private func lockedView() -> some View{
        if document.isLocked{
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 6) {
                    if let isLockAvailable, !isLockAvailable{
                        Text("需要您在设置中允许使用本地加密，用来启用文件加密")
                            .multilineTextAlignment(.center)
                            .frame(width: 300)
                    }else{
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                        
                        Text("查看需要验证\(Image(systemName: "faceid"))")
                    }
                }
                .padding(15)
                .background(.bar, in: .rect(cornerRadius: 10))
                .contentShape(.rect)
                .onTapGesture {
                    authenticateUser()
                }
            }
            .opacity(isUnlocked ? 0 : 1)
            .animation(snappy2, value: isUnlocked)
        }
    }
    
    private func createAndShareDocument(){
        guard let pages = document.pages?.sorted(by: {$0.pageIndex < $1.pageIndex}) else
        {
            return
        }
        
        isLoading = true
        Task.detached(priority: .high) {[document] in
            try await Task.sleep(for: .seconds(0.2))
            
            let pdfDoc = PDFDocument()
            for index in pages.indices{
                if let pageImage = UIImage(data: pages[index].pageData),
                   let pdfPage = PDFPage(image: pageImage){
                    pdfDoc.insert(pdfPage, at: index)
                }
            }
            
            var pdfUrl = FileManager.default.temporaryDirectory
            let fileName = "\(document.name).pdf".replace("/", with: "_")
            pdfUrl.append(path: fileName)
            
            if pdfDoc.write(to: pdfUrl){
                await MainActor.run { [pdfUrl] in
                    fileURL = pdfUrl
                    //保存文件的方式，已取消
                    //showFileMover = true
                    isLoading = false
                    
                    ///使用系统分享功能分享PDF文件
                    let vc  = UIActivityViewController(activityItems: [pdfUrl], applicationActivities: [])
                    let win = UIApplication.shared.connectedScenes
                                // Keep only active scenes, onscreen and visible to the user
                                .filter { $0.activationState == .foregroundActive }
                                // Keep only the first `UIWindowScene`
                                .first(where: { $0 is UIWindowScene })
                                // Get its associated windows
                                .flatMap({ $0 as? UIWindowScene })?.windows
                                // Finally, keep only the key window
                                .first(where: \.isKeyWindow)
                    win?.rootViewController?.present(vc, animated: true){}
                }
            }
        }
    }
    
    private func shareSingleImage(uiImage: UIImage){
        let vc  = UIActivityViewController(activityItems: [uiImage], applicationActivities: [])
        vc.title = "图片分享"
        let win = UIApplication.shared.connectedScenes
                    // Keep only active scenes, onscreen and visible to the user
                    .filter { $0.activationState == .foregroundActive }
                    // Keep only the first `UIWindowScene`
                    .first(where: { $0 is UIWindowScene })
                    // Get its associated windows
                    .flatMap({ $0 as? UIWindowScene })?.windows
                    // Finally, keep only the key window
                    .first(where: \.isKeyWindow)
        win?.rootViewController?.present(vc, animated: true){}
    }
    
    private func saveImageToAlbum(uiImage: UIImage) {
        // 请求相册权限
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                DispatchQueue.main.async {
                    MOLog("保存到相册成功")
                    $toasts.addToast(type: .sucessed("已成功保存到相册"))
                }
            } else {
                DispatchQueue.main.async {
                    MOLog("保存到相册失败，因为用户没有授权")
                    $toasts.addToast(type: .failed("保存失败，未授权相册写入"))
                }
            }
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "需要您在设置中允许使用本地加密，用来启用文件加密"){ status, _ in
                DispatchQueue.main.async {
                    self.isUnlocked = status
                }
                
            }
        }else{
            isLockAvailable = false
            isUnlocked = false
        }
        
    }
}

//
//  ToastVM.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/4/2.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI
import MKCoreTypes

///面包屑提示类型
enum ToastType{
    ///错误
    case failed(String)
    ///成功
    case sucessed(String)
    
    ///根据类型，返回系统图标
    func getIconName() -> String{
        switch self {
        case .failed(_):
            return "exclamationmark.triangle.fill"
        case .sucessed(_):
            return "checkmark.circle.fill"
        }
    }
    
    ///根据类型，返回系统图标
    func getIconColor() -> Color{
        switch self {
        case .failed(_):
            return .yellow
        case .sucessed(_):
            return .green
        }
    }
    
    ///根据类型，返回系统图标
    func getTipText() -> String{
        switch self {
        case .failed(let keyword):
            return  String(localized: "\(keyword)")
        case .sucessed(let keyword):
            return  String(localized: "\(keyword)")
        }
    }
}
///面包屑提示的数据模型
struct ToastVM: Identifiable{
    private(set) var id: String = UUID().uuidString
    var type: ToastType
    var content: AnyView
    init(type: ToastType, @ViewBuilder content: @escaping(String, ToastType) -> some View) {
        self.type = type
        self.content = .init(content(id, type))
    }
    
    var offsetX: CGFloat = .zero
    var isDeleting: Bool = false
}
///从模型本身移除面包屑的提示
extension Binding<[ToastVM]>{
    
    func addToast(type: ToastType) {
        MOLog("添加新的面包屑")
        withAnimation(.bouncy) {
            let toast = ToastVM(type: type){ id, type in
                StandardToastView(toasts: self, id: id, type: type)
            }
            self.wrappedValue.append(toast)
        }
    }
    ///清除当前所有的提示
    func cleanAll(){
        withAnimation(.bouncy) {
            self.wrappedValue.removeAll()
        }
    }
    
    func delete(id: String){
        if let toast = first(where: {$0.id == id}) {
            toast.wrappedValue.isDeleting = true
        }
        withAnimation(.bouncy) {
            self.wrappedValue.removeAll(where: {$0.id == id})
        }
    }
    ///用来测试，随机生成一个类型
//    private func getRandomType() -> ToastType {
//        let types = ToastType.allCases
//        guard !types.isEmpty else { return ToastType.keywordRec }
//
//        // 生成一个随机索引
//        let randomIndex = Int(arc4random_uniform(UInt32(types.count)))
//        return types[randomIndex]
//    }
}

//
//  ToastExtension.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/4/2.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI
///让View支持，面包屑的形式
extension View{
    @ViewBuilder
    func interactiveToasts(_ toasts: Binding<[ToastVM]>) -> some View{
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                ToastsView(toasts: toasts)
            }
    }
}
///全局显示的面包屑的View
struct ToastsView: View {
    @Binding var toasts: [ToastVM]
    @State private var isExpanded: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isExpanded {
                ///毛玻璃效果遮罩层
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.9)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isExpanded = false
                    }
            }
            
            let layout = isExpanded ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())
            layout {
                ForEach($toasts) { $toast in
                    let index = (toasts.count - 1) - (toasts.firstIndex(where: {$0.id == toast.id}) ?? 0)
                    toast.content
                        .offset(x: toast.offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged{ value in
                                    let xOffset = value.translation.width < 0 ? value.translation.width : 0
                                    toast.offsetX = xOffset
                                }.onEnded{ value in
                                    let xOffset = value.translation.width + (value.velocity.width / 2)
                                    
                                    if -xOffset > 200{
                                        //关闭面包屑
                                        $toasts.delete(id: toast.id)
                                    }else{
                                        toast.offsetX = .zero
                                    }
                                }
                        )
                        .visualEffect { [isExpanded] content, proxy in
                            content
                                .scaleEffect(isExpanded ? 1 : scale(index), anchor: .bottom)
                                .offset(y: isExpanded ? 0 : offsetY(index))
                        }
                        .zIndex(toast.isDeleting ? 1000 : 0)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(insertion: .offset(y: 100), removal: .move(edge: .leading)))
                }
            }
            .padding(.bottom, 15)
            .onTapGesture {
                isExpanded.toggle()
            }
        }
        .animation(.bouncy, value:  isExpanded)
        .onChange(of: toasts.isEmpty) { oldValue, newValue in
            if newValue{
                isExpanded = false
            }
        }

    }
    
    nonisolated func offsetY(_ index: Int) -> CGFloat {
        let offset = min(CGFloat(index) * 15, 30)
        
        return -offset
    }
    
    nonisolated func scale(_ index: Int) -> CGFloat {
        let scale = min(CGFloat(index) * 0.1, 1)
        
        return 1 - scale
    }
}

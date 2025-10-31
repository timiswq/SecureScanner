//
//  View+Extensions.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/26.
//  Copyright © 2025 Tim. All rights reserved.
//
import SwiftUI
extension View{
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View{
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View{
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func loadingScreen(status: Binding<Bool>) -> some View{
        self.overlay {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                ProgressView()
                    .frame(width: 40, height: 40)
                    .background(.bar, in: .rect(cornerRadius: 10))
            }
            .opacity(status.wrappedValue ? 1: 0)
            .allowsHitTesting(status.wrappedValue)
            .animation(snappy2, value: status.wrappedValue)
        }
    }
    
    var snappy2: Animation{
        .snappy(duration: 0.25, extraBounce: 0)
    }
    
    @ViewBuilder
    func alert<Content: View, Background: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder background: @escaping () -> Background) -> some View{
            self
                .modifier(CustomAlertModifier(isPresented: isPresented, alertContent: content, background: background))
        }
}

fileprivate struct CustomAlertModifier<AlertContent: View, Background: View>: ViewModifier{
    @Binding var isPresented: Bool
    @ViewBuilder var alertContent: AlertContent
    @ViewBuilder var background: Background
    
    @State private var showFullScreenCover: Bool = false
    @State private var animatiedValue: Bool = false
    @State private var  allowInteraction: Bool = false
    
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showFullScreenCover) {
                ZStack {
                    if animatiedValue{
                        alertContent
                            .allowsTightening(allowInteraction)
                    }
                }
                .presentationBackground {
                    background
                        .allowsTightening(allowInteraction)
                        .opacity(animatiedValue ? 1 : 0)
                }
                .task {
                    try? await Task.sleep(for: .seconds(0.05))
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animatiedValue = true
                    }
                    
                    try? await Task.sleep(for: .seconds(0.3))
                    allowInteraction = true
                }
            }
            .onChange(of: isPresented) { oldValue, newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                
                if newValue {
                    withTransaction(transaction) {
                        showFullScreenCover = true
                    }
                }else{
                    allowInteraction = false
                    withAnimation(.easeInOut(duration: 0.3), completionCriteria: .removed) {
                        animatiedValue = false
                    } completion: {
                        withTransaction(transaction) {
                            showFullScreenCover = false
                        }
                    }

                }
            }
    }
}

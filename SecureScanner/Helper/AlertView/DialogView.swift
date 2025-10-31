//
//  DialogView.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/27.
//  Copyright © 2025 Tim. All rights reserved.
//
import SwiftUI

struct CustomDialogView: View {
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: (String) -> () = {_ in }
    }
    var title: String
    var content: String?
    var image: Config
    var button1: Config
    var button2: Config?
    var addsTextField: Bool = false
    var textFieldHint: String = ""
    @Binding var text: String
    var btn1Disabled: Bool
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: image.content)
                .font(.title)
                .foregroundStyle(image.foreground)
                .frame(width: 65, height: 65)
                .background(image.tint.gradient, in: .circle)
                .background(
                    Circle()
                        .stroke(.background, lineWidth: 8)
                )
            
            Text("\(title)")
                .font(.title3.bold())
            
            if let content {
                Text("\(content)")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
            }
            
            if addsTextField{
                HStack {
                    TextField(textFieldHint, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // 添加边框样式
                    if !text.isEmpty { // 只有在有输入内容时才显示清除按钮
                        Button(action: {
                            text = "" // 清空输入框
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle()) // 让按钮更符合系统风格
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.gray.opacity(0.1))
                }
                .padding(.bottom, 5)
            }
            HStack {
                ButtonView(button1, isDisabled: btn1Disabled)
                    
                if let button2 {
                    ButtonView(button2, isDisabled: false)
                        .padding(.top, 5)
                }
            }
            .padding()
        }
        .padding([.horizontal, .bottom], 15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .padding(.top, 30)
        }
        .frame(maxWidth: 310)
        .compositingGroup()
    }
    
    @ViewBuilder
    private func ButtonView(_ config: Config, isDisabled: Bool) -> some View{
        Button {
            config.action(addsTextField ? text : "")
        } label: {
            Text(config.content)
                .fontWeight(.bold)
                .foregroundStyle(config.foreground)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isDisabled ? Color.gray.gradient : config.tint.gradient, in: .rect(cornerRadius: 10))
        }
        .disabled(isDisabled)
    }
}

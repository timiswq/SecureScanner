//
//  ToastView.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/4/2.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI
import MKCoreTypes
import MKCommonUI

///标准的单个面包屑提示窗口的样式
struct StandardToastView: View {
    @Binding var toasts : [ToastVM]
    var id: String
    var type: ToastType
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.getIconName())
                .foregroundStyle(type.getIconColor())
                
            Button {
                switch type {
                case .sucessed(let keyword):
                    MOLog("执行成功 \(keyword)")
                    break
                case .failed(let keyword):
                    MOLog("出错了： \(keyword)")
                    break
                }
            } label: {
                Text(type.getTipText())
                    .foregroundStyle(Color.markonceRed)
            }
            Spacer(minLength: 0)
            
            Button {
                $toasts.delete(id: id)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }

        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .primary.opacity(0.1), radius: 3, x: -1, y: -3)
                .shadow(color: .primary.opacity(0.1), radius: 2, x: 1, y: 3)
        }
        .padding(.horizontal, 15)
    }
}

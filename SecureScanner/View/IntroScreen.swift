//
//  IntroScreen.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/26.
//  Copyright © 2025 Tim. All rights reserved.
//

import SwiftUI
import MKCommonUI

struct IntroScreen: View {
    @AppStorage("showIntroView") private var showIntroView: Bool = true

    var body: some View {
        VStack(spacing: 15) {
            Text("\(AppName)\n新功能介绍")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 65)
                .padding(.bottom, 35)
            
            VStack(alignment: .leading, spacing: 25) {
                PointView(
                    title: "随身扫描",
                    image: "scanner",
                    desc: "开箱即用随手扫描，AI自动对齐，A4、身份证等多种格式"
                )
                
                PointView(
                    title: "隐私保护",
                    image: "faceid",
                    desc: "文件本地保存，查看、分享文件需要FaceID认证"
                )
                
                PointView(
                    title: "本地无注册",
                    image: "tray.full.fill",
                    desc: "无网络请求，无第三方插件，不需要手机号注册，终身无广"
                )
            }
            .padding(.horizontal, 25)
            
            Spacer(minLength: 0)
            
            Button {
                showIntroView = false
            } label: {
                Text("开始保密文件扫描")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color.markonceRed.gradient, in: .capsule)
            }

        }
        .padding(15)
    }
    
    @ViewBuilder
    private func PointView(title: String, image: String, desc: String) -> some View{
        HStack(spacing: 15) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundStyle(Color.markonceRed)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(desc)
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    IntroScreen()
}

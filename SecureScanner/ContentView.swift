//
//  ContentView.swift
//  SecureScanner
//
//  Created by Qing Wang on 2025/10/31.
//

import SwiftUI
///获取APP的显示名称
let AppName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
    @AppStorage("showIntroView") private var showIntroView: Bool = true
    @State private var showIntro = true
    var body: some View {
        Home()
//            .sheet(isPresented: $showIntro) {
//                //仅用于测试演示
//                IntroScreen()
//            }
            .sheet(isPresented: $showIntroView) {
                IntroScreen()
                    .interactiveDismissDisabled()
            }
//            .fullScreenCover(isPresented: $showIntroView) {
//                IntroScreen()
//                    .interactiveDismissDisabled()
//            }
    }
}
#Preview {
    ContentView()
}

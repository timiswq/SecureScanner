//
//  Date+Extensions.swift
//  MarkOnce_SwiftUI
//
//  Created by Qing Wang on 2025/2/27.
//  Copyright © 2025 Tim. All rights reserved.
//
import Foundation

extension Date{
    /// 设定格式为 20250227_0910
    func formatDate4FileName() -> String {
        let formatter = DateFormatter()
        // 设定格式为 20250227_0910
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter.string(from: self)
    }
}


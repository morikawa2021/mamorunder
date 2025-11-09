//
//  RepeatPattern.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import Foundation

// 繰り返しパターンのタイプ
public enum RepeatType: String, Codable {
    case daily = "daily"                     // 毎日
    case weekly = "weekly"                   // 毎週
    case monthly = "monthly"                 // 毎月
    case yearly = "yearly"                   // 毎年
    case everyNDays = "everyNDays"           // N日ごと
    case nthWeekdayOfMonth = "nthWeekdayOfMonth" // 毎月第N曜日
    case custom = "custom"                   // カスタム
}

// 繰り返しパターン（パラメータを含む）
// Core DataのTransformable属性で使用するため、NSObjectを継承
@objc(RepeatPattern)
public class RepeatPattern: NSObject, Codable {
    public let type: RepeatType                     // パターンタイプ
    public let interval: Int?                       // N日ごと の N（everyNDaysの場合）
    public let weekday: Int?                        // 曜日（1=日曜日〜7=土曜日、nthWeekdayOfMonthの場合）
    public let week: Int?                           // 第N週（1=第1週、nthWeekdayOfMonthの場合）
    public let customDays: [Int]?                   // カスタムパターンの曜日（customの場合）
    
    public init(type: RepeatType, interval: Int?, weekday: Int?, week: Int?, customDays: [Int]?) {
        self.type = type
        self.interval = interval
        self.weekday = weekday
        self.week = week
        self.customDays = customDays
        super.init()
    }

    // 便利なイニシャライザ
    public static func daily() -> RepeatPattern {
        return RepeatPattern(type: .daily, interval: nil, weekday: nil, week: nil, customDays: nil)
    }

    public static func weekly() -> RepeatPattern {
        return RepeatPattern(type: .weekly, interval: nil, weekday: nil, week: nil, customDays: nil)
    }

    public static func monthly() -> RepeatPattern {
        return RepeatPattern(type: .monthly, interval: nil, weekday: nil, week: nil, customDays: nil)
    }

    public static func yearly() -> RepeatPattern {
        return RepeatPattern(type: .yearly, interval: nil, weekday: nil, week: nil, customDays: nil)
    }

    public static func everyNDays(_ n: Int) -> RepeatPattern {
        return RepeatPattern(type: .everyNDays, interval: n, weekday: nil, week: nil, customDays: nil)
    }

    public static func nthWeekdayOfMonth(weekday: Int, week: Int) -> RepeatPattern {
        return RepeatPattern(type: .nthWeekdayOfMonth, interval: nil, weekday: weekday, week: week, customDays: nil)
    }

    public static func custom(days: [Int]) -> RepeatPattern {
        return RepeatPattern(type: .custom, interval: nil, weekday: nil, week: nil, customDays: days)
    }
}

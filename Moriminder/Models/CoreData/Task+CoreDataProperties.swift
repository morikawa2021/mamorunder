//
//  Task+CoreDataProperties.swift
//  Moriminder
//
//  Created on 2025-11-09.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

extension Task {
    // repeatPatternDataをRepeatPatternに変換するcomputed property
    public var repeatPattern: RepeatPattern? {
        get {
            guard let data = repeatPatternData else { return nil }
            return try? JSONDecoder().decode(RepeatPattern.self, from: data)
        }
        set {
            if let pattern = newValue {
                repeatPatternData = try? JSONEncoder().encode(pattern)
            } else {
                repeatPatternData = nil
            }
        }
    }
    
    // awakeFromInsertでデフォルト値を設定
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // createdAtが設定されていない場合、現在日時を設定
        if createdAt == nil {
            createdAt = Date()
        }
        
        // idが設定されていない場合、新しいUUIDを生成
        if id == nil {
            id = UUID()
        }
        
        // デフォルト値の設定（初回作成時のみ）
        alarmEnabled = false
        reminderEnabled = false
        reminderInterval = 60
        snoozeMaxCount = 5
        snoozeUnlimited = false
        snoozeCount = 0
        isRepeating = false
        isCompleted = false
        isArchived = false
    }
}


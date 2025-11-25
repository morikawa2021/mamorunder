//
//  TaskDetailViewModel.swift
//  Moriminder
//
//  Created on 2025-11-19.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class TaskDetailViewModel: ObservableObject {
    @Published var task: Task
    @Published var isCompleting: Bool = false
    @Published var showEditSheet: Bool = false

    private var taskManager: TaskManager
    private var viewContext: NSManagedObjectContext

    init(task: Task, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.task = task
        self.viewContext = viewContext
        self.taskManager = TaskManager(viewContext: viewContext)
    }

    // MARK: - Formatted Display Properties

    var formattedPriority: String {
        guard let priorityString = task.priority,
              let priority = Priority(rawValue: priorityString) else {
            return "中"
        }
        switch priority {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    var formattedTaskType: String {
        guard let taskTypeString = task.taskType,
              let taskType = TaskType(rawValue: taskTypeString) else {
            return "タスク"
        }
        switch taskType {
        case .task: return "タスク"
        case .schedule: return "予定"
        }
    }

    var formattedDeadline: String {
        guard let deadline = task.deadline else {
            return "未設定"
        }
        return formatDate(deadline)
    }

    var formattedStartDateTime: String {
        guard let startDateTime = task.startDateTime else {
            return "未設定"
        }
        return formatDateTime(startDateTime)
    }

    var formattedAlarm: String {
        guard task.alarmEnabled, let alarmDateTime = task.alarmDateTime else {
            return "オフ"
        }
        return formatDateTime(alarmDateTime)
    }

    var formattedReminder: String {
        guard task.reminderEnabled else {
            return "オフ"
        }

        let interval = formatReminderInterval(Int(task.reminderInterval))

        var components: [String] = [interval]

        if let startTime = task.reminderStartTime {
            components.append("開始: \(formatDateTime(startTime))")
        }

        if let endTime = task.reminderEndTime {
            components.append("終了: \(formatDateTime(endTime))")
        } else {
            components.append("完了まで継続")
        }

        return components.joined(separator: "\n")
    }

    var formattedRepeat: String {
        guard task.isRepeating, let repeatPattern = task.repeatPattern else {
            return "なし"
        }

        let patternText = formatRepeatPattern(repeatPattern)

        if let endDate = task.repeatEndDate {
            return "\(patternText)\n(\(formatDate(endDate))まで)"
        }

        return patternText
    }

    var categoryName: String {
        task.category?.name ?? "未分類"
    }

    var categoryColor: Color {
        if let colorHex = task.category?.color {
            return Color(hex: colorHex) ?? .gray
        }
        return .gray
    }

    var isCompleted: Bool {
        task.isCompleted
    }

    // MARK: - Actions

    func completeTask() async throws {
        await MainActor.run {
            isCompleting = true
        }

        defer {
            _Concurrency.Task { @MainActor in
                isCompleting = false
            }
        }

        try await taskManager.completeTask(task)

        // タスクの状態を更新
        await MainActor.run {
            self.task = task
        }
    }

    func refreshTask() {
        // タスクを再取得して最新の状態を反映
        if let taskId = task.id,
           let refreshedTask = taskManager.fetchTask(id: taskId) {
            self.task = refreshedTask
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func formatReminderInterval(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)分ごと"
        } else if minutes < 1440 {
            let hours = minutes / 60
            return "\(hours)時間ごと"
        } else {
            let days = minutes / 1440
            return "\(days)日ごと"
        }
    }

    private func formatRepeatPattern(_ pattern: RepeatPattern) -> String {
        switch pattern.type {
        case .daily:
            return "毎日"
        case .weekly:
            return "毎週"
        case .monthly:
            return "毎月"
        case .yearly:
            return "毎年"
        case .custom:
            return "カスタム"
        case .nthWeekdayOfMonth:
            if let weekday = pattern.weekday, let week = pattern.week {
                let weekdayNames = ["", "日", "月", "火", "水", "木", "金", "土"]
                let weekdayName = weekday >= 1 && weekday <= 7 ? weekdayNames[weekday] : "?"
                return "毎月第\(week)\(weekdayName)曜日"
            }
            return "月の第N週"
        case .everyNDays:
            if let interval = pattern.interval {
                return "\(interval)日ごと"
            }
            return "N日ごと"
        case .everyNHours:
            if let hourInterval = pattern.hourInterval {
                return "\(hourInterval)時間ごと"
            }
            return "N時間ごと"
        }
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

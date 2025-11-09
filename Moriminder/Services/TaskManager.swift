//
//  TaskManager.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import Foundation
import CoreData

class TaskManager {
    private let viewContext: NSManagedObjectContext
    private let notificationManager: NotificationManager
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.notificationManager = NotificationManager()
    }
    
    // タスク作成
    func createTask(_ task: Task) async throws {
        // 1. バリデーション
        try validateTask(task)
        
        // 2. 保存
        try viewContext.save()
        
        // 3. 通知スケジュール
        if task.alarmEnabled {
            try await notificationManager.scheduleAlarm(for: task)
        }
        if task.reminderEnabled {
            try await notificationManager.scheduleReminder(for: task)
        }
        
        // 4. 繰り返しタスクの場合は次回インスタンスを生成
        if task.isRepeating {
            // TODO: 繰り返しタスク生成
        }
    }
    
    // IDでタスクを取得
    func fetchTask(id: UUID) -> Task? {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("タスク取得エラー: \(error)")
            return nil
        }
    }
    
    // タスク取得
    func fetchTasks(filter: FilterMode = .all, sort: SortMode = .createdAtDesc) -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        // フィルタの適用
        var predicates: [NSPredicate] = []
        
        switch filter {
        case .all:
            break
        case .incomplete:
            predicates.append(NSPredicate(format: "isCompleted == NO"))
        case .completed:
            predicates.append(NSPredicate(format: "isCompleted == YES"))
        case .category(let categoryName):
            predicates.append(NSPredicate(format: "category.name == %@", categoryName))
        case .priority(let priority):
            predicates.append(NSPredicate(format: "priority == %@", priority.rawValue))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // ソートの適用
        switch sort {
        case .createdAtDesc:
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        case .createdAtAsc:
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        case .priority:
            request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        case .deadline:
            request.sortDescriptors = [NSSortDescriptor(key: "deadline", ascending: true)]
        case .startDateTime:
            request.sortDescriptors = [NSSortDescriptor(key: "startDateTime", ascending: true)]
        case .alarmDateTime:
            request.sortDescriptors = [NSSortDescriptor(key: "alarmDateTime", ascending: true)]
        case .category:
            request.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true)]
        case .alphabetical:
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("タスク取得エラー: \(error)")
            return []
        }
    }
    
    // タスク完了
    func completeTask(_ task: Task) async throws {
        // 1. タスクを完了状態に更新
        task.isCompleted = true
        task.completedAt = Date()
        
        // 2. 通知をキャンセル
        try await notificationManager.cancelNotifications(for: task)
        
        // 3. 保存
        try viewContext.save()
        
        // 4. 繰り返しタスクの場合は次回インスタンスを生成
        if task.isRepeating {
            // TODO: 繰り返しタスク生成
        }
    }
    
    // タスク削除
    func deleteTask(_ task: Task) async throws {
        // 1. 通知をキャンセル
        try await notificationManager.cancelNotifications(for: task)
        
        // 2. 削除
        viewContext.delete(task)
        try viewContext.save()
    }
    
    // バリデーション
    private func validateTask(_ task: Task) throws {
        guard let title = task.title, !title.isEmpty else {
            throw TaskError.invalidTitle
        }
        
        // 日時設定のバリデーション
        if let deadline = task.deadline, let startDateTime = task.startDateTime {
            guard deadline >= startDateTime else {
                throw TaskError.conflictingDates
            }
        }
    }
}


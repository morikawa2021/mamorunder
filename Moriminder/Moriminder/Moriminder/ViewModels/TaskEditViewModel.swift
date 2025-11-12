//
//  TaskEditViewModel.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class TaskEditViewModel: ObservableObject {
    enum Mode {
        case create
        case edit(Task)
    }
    
    @Published var title: String = ""
    @Published var category: Category?
    @Published var priority: Priority = .medium
    @Published var taskType: TaskType = .task
    @Published var deadline: Date?
    @Published var startDateTime: Date?
    @Published var alarmEnabled: Bool = false
    @Published var alarmDateTime: Date?
    @Published var alarmSound: String?
    @Published var reminderEnabled: Bool = false
    @Published var reminderInterval: Int = 60
    @Published var reminderStartTime: Date?
    @Published var reminderEndTime: Date?
    @Published var isRepeating: Bool = false
    @Published var repeatPattern: RepeatPattern?
    @Published var repeatEndDate: Date?
    
    @Published var categories: [Category] = []
    @Published var presetTimes: [PresetTime] = []
    @Published var isSaving: Bool = false
    
    var isValid: Bool {
        !title.isEmpty && !isSaving
    }
    
    private let mode: Mode
    private var taskManager: TaskManager
    private var viewContext: NSManagedObjectContext
    
    init(mode: Mode, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.mode = mode
        self.viewContext = viewContext
        self.taskManager = TaskManager(viewContext: viewContext)
        
        // 編集モードの場合、既存のタスクデータを読み込む
        if case .edit(let task) = mode {
            loadTask(task)
        }
        
        loadCategories()
        loadPresetTimes()
    }
    
    func updateViewContext(_ newViewContext: NSManagedObjectContext) {
        self.viewContext = newViewContext
        self.taskManager = TaskManager(viewContext: newViewContext)
        // viewContextが変更されたので、カテゴリとプリセット時間を再読み込み
        loadCategories()
        loadPresetTimes()
    }
    
    private func loadTask(_ task: Task) {
        title = task.title ?? ""
        category = task.category
        if let priorityString = task.priority {
            priority = Priority(rawValue: priorityString) ?? .medium
        }
        if let taskTypeString = task.taskType {
            taskType = TaskType(rawValue: taskTypeString) ?? .task
        }
        deadline = task.deadline
        startDateTime = task.startDateTime
        alarmEnabled = task.alarmEnabled
        alarmDateTime = task.alarmDateTime
        alarmSound = task.alarmSound
        reminderEnabled = task.reminderEnabled
        reminderInterval = Int(task.reminderInterval)
        reminderStartTime = task.reminderStartTime
        reminderEndTime = task.reminderEndTime
        isRepeating = task.isRepeating
        repeatPattern = task.repeatPattern
        repeatEndDate = task.repeatEndDate
    }
    
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "usageCount", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            categories = try viewContext.fetch(request)
        } catch {
            print("カテゴリ取得エラー: \(error)")
            categories = []
        }
    }
    
    private func loadPresetTimes() {
        let request: NSFetchRequest<PresetTime> = PresetTime.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "isDefault", ascending: false),
            NSSortDescriptor(key: "order", ascending: true)
        ]
        
        do {
            presetTimes = try viewContext.fetch(request)
        } catch {
            print("プリセット時間取得エラー: \(error)")
            presetTimes = []
        }
    }
    
    func save() async throws {
        // 保存中のフラグを設定
        await MainActor.run {
            isSaving = true
        }
        
        defer {
            _Concurrency.Task { @MainActor in
                isSaving = false
            }
        }
        
        let task: Task
        
        switch mode {
        case .create:
            // 新規作成
            task = Task(context: viewContext)
            task.createdAt = Date()
            task.id = UUID()
        case .edit(let existingTask):
            // 編集
            // 既存のタスクが別のコンテキストに属している場合は、現在のコンテキストに取得し直す
            if existingTask.managedObjectContext != viewContext {
                // 別のコンテキストのタスクを現在のコンテキストで取得
                guard let taskId = existingTask.id else {
                    throw TaskError.taskNotFound
                }
                if let taskInContext = taskManager.fetchTask(id: taskId) {
                    task = taskInContext
                } else {
                    throw TaskError.taskNotFound
                }
            } else {
                task = existingTask
            }
        }
        
        // 基本情報の設定
        task.title = title
        task.category = category
        task.priority = priority.rawValue
        task.taskType = taskType.rawValue
        task.deadline = deadline
        task.startDateTime = startDateTime
        
        // アラーム設定
        task.alarmEnabled = alarmEnabled
        // alarmEnabledがtrueでalarmDateTimeがnilの場合、defaultDateTime（deadlineまたはstartDateTime）を設定
        if alarmEnabled && alarmDateTime == nil {
            let defaultDateTime = taskType == .task ? deadline : startDateTime
            if let defaultDateTime = defaultDateTime {
                task.alarmDateTime = defaultDateTime
                print("⚠️ アラームが有効ですがalarmDateTimeがnilのため、defaultDateTimeを設定しました: \(defaultDateTime)")
            } else {
                // defaultDateTimeもnilの場合は現在時刻を設定
                task.alarmDateTime = Date()
                print("⚠️ アラームが有効ですがalarmDateTimeとdefaultDateTimeがnilのため、現在時刻を設定しました")
            }
        } else {
            task.alarmDateTime = alarmDateTime
        }
        task.alarmSound = alarmSound
        
        print("💾 タスク保存: \(title)")
        print("  - alarmEnabled: \(alarmEnabled)")
        print("  - alarmDateTime: \(alarmDateTime?.description ?? "nil")")
        print("  - task.alarmEnabled: \(task.alarmEnabled)")
        print("  - task.alarmDateTime: \(task.alarmDateTime?.description ?? "nil")")
        
        // リマインド設定
        task.reminderEnabled = reminderEnabled
        task.reminderInterval = Int32(reminderInterval)
        task.reminderStartTime = reminderStartTime
        task.reminderEndTime = reminderEndTime

        // 繰り返し設定
        task.isRepeating = isRepeating
        task.repeatPattern = repeatPattern
        task.repeatEndDate = repeatEndDate
        
        // カテゴリの使用回数をインクリメント
        if let category = category {
            category.usageCount += 1
        }
        
        // 保存と通知スケジュール
        try await taskManager.createTask(task)
    }
}


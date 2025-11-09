//
//  DateSettingView.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import SwiftUI

struct DateSettingView: View {
    @Binding var taskType: TaskType
    @Binding var deadline: Date?
    @Binding var startDateTime: Date?
    let presetTimes: [PresetTime]
    
    var body: some View {
        Group {
            Picker("種類", selection: $taskType) {
                Text("期限").tag(TaskType.task)
                Text("開始日時").tag(TaskType.schedule)
            }
            .pickerStyle(.segmented)
            
            if taskType == .task {
                DatePicker("期限", selection: Binding(
                    get: { deadline ?? Date() },
                    set: { deadline = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
            } else {
                DatePicker("開始日時", selection: Binding(
                    get: { startDateTime ?? Date() },
                    set: { startDateTime = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
            }
        }
        .environment(\.locale, Locale(identifier: "ja_JP"))
        
        // プリセット時間の表示
        if !presetTimes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presetTimes, id: \.objectID) { preset in
                        PresetTimeButton(
                            preset: preset,
                            taskType: taskType,
                            deadline: $deadline,
                            startDateTime: $startDateTime
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


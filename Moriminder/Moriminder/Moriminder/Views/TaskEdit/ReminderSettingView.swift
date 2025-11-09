//
//  ReminderSettingView.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import SwiftUI

struct ReminderSettingView: View {
    @Binding var enabled: Bool
    @Binding var interval: Int
    let priority: Priority
    let taskType: TaskType
    @Binding var snoozeMaxCount: Int
    
    @State private var useDefaultSettings: Bool = true
    
    // 重要度とタスクタイプに応じたデフォルト間隔
    private var defaultInterval: Int {
        switch (priority, taskType) {
        case (.low, .task):
            return 1440  // 24時間間隔
        case (.medium, .task):
            return 180   // 3時間間隔
        case (.high, .task):
            return 60    // 1時間間隔
        case (.low, .schedule), (.medium, .schedule), (.high, .schedule):
            // スケジュールの場合は段階的リマインドのため、最初の間隔を返す
            return 60    // デフォルト1時間間隔
        }
    }
    
    var body: some View {
        Toggle("リマインド", isOn: $enabled)
        
        if enabled {
            // デフォルト設定を使用するかどうかの選択
            Toggle("デフォルト設定を使用", isOn: $useDefaultSettings)
                .onChange(of: useDefaultSettings) { newValue in
                    if newValue {
                        interval = defaultInterval
                    }
                }
                .onChange(of: priority) { _ in
                    if useDefaultSettings {
                        interval = defaultInterval
                    }
                }
                .onChange(of: taskType) { _ in
                    if useDefaultSettings {
                        interval = defaultInterval
                    }
                }
            
            if !useDefaultSettings {
                Picker("間隔", selection: $interval) {
                    Text("5分").tag(5)
                    Text("15分").tag(15)
                    Text("30分").tag(30)
                    Text("1時間").tag(60)
                    Text("3時間").tag(180)
                    Text("6時間").tag(360)
                    Text("12時間").tag(720)
                    Text("24時間").tag(1440)
                }
            } else {
                // デフォルト設定の表示
                HStack {
                    Text("間隔:")
                    Spacer()
                    Text(formatInterval(defaultInterval))
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }
            
            Stepper("スヌーズ最大回数: \(snoozeMaxCount)回", value: $snoozeMaxCount, in: 1...10)
        }
    }
    
    private func formatInterval(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)分"
        } else if minutes < 1440 {
            return "\(minutes / 60)時間"
        } else {
            return "\(minutes / 1440)日"
        }
    }
}


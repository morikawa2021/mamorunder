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
    
    var body: some View {
        Toggle("リマインド", isOn: $enabled)
        
        if enabled {
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
            
            Stepper("スヌーズ最大回数: \(snoozeMaxCount)回", value: $snoozeMaxCount, in: 1...10)
        }
    }
}


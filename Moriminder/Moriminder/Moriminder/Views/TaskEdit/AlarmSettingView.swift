//
//  AlarmSettingView.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import SwiftUI

struct AlarmSettingView: View {
    @Binding var enabled: Bool
    @Binding var dateTime: Date?
    @Binding var sound: String?
    let defaultDateTime: Date?  // 期限設定の時刻（デフォルト値として使用）
    
    var body: some View {
        Group {
            Toggle("アラーム", isOn: $enabled)
            
            if enabled {
                DatePicker("アラーム時刻", selection: Binding(
                    get: { dateTime ?? defaultDateTime ?? Date() },
                    set: { dateTime = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
                
                // TODO: アラーム音の選択
            }
        }
        .environment(\.locale, Locale(identifier: "ja_JP"))
        .onChange(of: enabled) { newValue in
            // アラームを有効にしたとき、dateTimeがnilならdefaultDateTimeを設定
            if newValue && dateTime == nil {
                let newDateTime = defaultDateTime ?? Date()
                print("🔔 AlarmSettingView: enabledが\(newValue)に変更されました")
                print("  - dateTime: \(dateTime?.description ?? "nil")")
                print("  - defaultDateTime: \(defaultDateTime?.description ?? "nil")")
                print("  - 設定する値: \(newDateTime)")
                dateTime = newDateTime
            }
        }
        .onChange(of: defaultDateTime) { newValue in
            // defaultDateTimeが変更されたとき、dateTimeがnilでenabledがtrueなら更新
            if enabled && dateTime == nil, let newDateTime = newValue {
                print("🔔 AlarmSettingView: defaultDateTimeが変更されました")
                print("  - 新しいdefaultDateTime: \(newDateTime)")
                dateTime = newDateTime
            }
        }
    }
}


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
    
    var body: some View {
        Group {
            Toggle("アラーム", isOn: $enabled)
            
            if enabled {
                DatePicker("アラーム時刻", selection: Binding(
                    get: { dateTime ?? Date() },
                    set: { dateTime = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
                
                // TODO: アラーム音の選択
            }
        }
        .environment(\.locale, Locale(identifier: "ja_JP"))
    }
}


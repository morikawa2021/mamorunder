//
//  FilterSortBar.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import SwiftUI

enum FilterMode {
    case all
    case incomplete
    case completed
    case category(String)
    case priority(Priority)
}

enum SortMode {
    case createdAtDesc
    case createdAtAsc
    case priority
    case deadline
    case startDateTime
    case alarmDateTime
    case category
    case alphabetical
}

struct FilterSortBar: View {
    @Binding var filterMode: FilterMode
    @Binding var sortMode: SortMode
    
    var body: some View {
        HStack {
            // フィルタボタン
            Menu {
                Button("すべて") {
                    filterMode = .all
                }
                Button("未完了") {
                    filterMode = .incomplete
                }
                Button("完了済み") {
                    filterMode = .completed
                }
            } label: {
                Label("フィルタ", systemImage: "line.3.horizontal.decrease.circle")
            }
            
            Spacer()
            
            // ソートボタン
            Menu {
                Button("登録日時（新しい順）") {
                    sortMode = .createdAtDesc
                }
                Button("登録日時（古い順）") {
                    sortMode = .createdAtAsc
                }
                Button("重要度") {
                    sortMode = .priority
                }
                Button("期限") {
                    sortMode = .deadline
                }
                Button("開始日時") {
                    sortMode = .startDateTime
                }
            } label: {
                Label("ソート", systemImage: "arrow.up.arrow.down")
            }
        }
        .padding()
    }
}


//
//  CategoryManager.swift
//  Moriminder
//
//  Created on 2025-11-09.
//

import Foundation
import CoreData

class CategoryManager {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    // カテゴリを名前で検索または作成
    func findOrCreateCategory(name: String, color: String = "#007AFF") -> Category {
        // 既存のカテゴリを検索
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        if let existingCategory = try? viewContext.fetch(request).first {
            return existingCategory
        }
        
        // 新規作成
        let category = Category(context: viewContext)
        category.id = UUID()
        category.name = name
        category.color = color
        category.createdAt = Date()
        category.usageCount = 0
        
        return category
    }
    
    // カテゴリ一覧を取得（使用回数順）
    func fetchCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "usageCount", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("カテゴリ取得エラー: \(error)")
            return []
        }
    }
    
    // カテゴリ名で検索（オートコンプリート用）
    func searchCategories(query: String) -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        request.sortDescriptors = [
            NSSortDescriptor(key: "usageCount", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("カテゴリ検索エラー: \(error)")
            return []
        }
    }
    
    // カテゴリを削除
    func deleteCategory(_ category: Category) throws {
        viewContext.delete(category)
        try viewContext.save()
    }
    
    // カテゴリの色を更新
    func updateCategoryColor(_ category: Category, color: String) throws {
        category.color = color
        try viewContext.save()
    }
    
    // カテゴリ名を更新
    func updateCategoryName(_ category: Category, name: String) throws {
        category.name = name
        try viewContext.save()
    }
}

// カテゴリの色定義
extension CategoryManager {
    static let defaultColors: [String] = [
        "#007AFF", // 青
        "#FF3B30", // 赤
        "#34C759", // 緑
        "#FF9500", // オレンジ
        "#AF52DE", // 紫
        "#FF69B4", // ピンク（より明るいピンクに変更）
        "#5AC8FA", // 水色
        "#FFCC00", // 黄
    ]
    
    static func colorFromHex(_ hex: String) -> Color {
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

import SwiftUI


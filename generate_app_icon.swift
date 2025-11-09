#!/usr/bin/env swift

import AppKit
import SwiftUI

// SF Symbolからアプリアイコン画像を生成するスクリプト
// 使用方法: swift generate_app_icon.swift

let iconSize = 1024.0
let symbolName = "bell.badge.fill"
let outputPath = "AppIcon.png"

// SF Symbolを画像としてレンダリング
let config = NSImage.SymbolConfiguration(pointSize: iconSize * 0.7, weight: .regular)
let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)

guard let symbolImage = image?.withSymbolConfiguration(config) else {
    print("エラー: SF Symbol '\(symbolName)' が見つかりません")
    exit(1)
}

// 背景色付きの画像を作成
let size = NSSize(width: iconSize, height: iconSize)
let finalImage = NSImage(size: size)
finalImage.lockFocus()

// 背景を描画（青）
NSColor.systemBlue.setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()

// シンボルを中央に配置
let symbolRect = NSRect(
    x: iconSize * 0.15,
    y: iconSize * 0.15,
    width: iconSize * 0.7,
    height: iconSize * 0.7
)
symbolImage.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)

finalImage.unlockFocus()

// PNGとして保存
guard let tiffData = finalImage.tiffRepresentation,
      let bitmapImage = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
    print("エラー: 画像の生成に失敗しました")
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("アプリアイコン画像を生成しました: \(outputPath)")
    print("この画像をXcodeのAppIcon.appiconsetに追加してください。")
} catch {
    print("エラー: ファイルの保存に失敗しました: \(error)")
    exit(1)
}


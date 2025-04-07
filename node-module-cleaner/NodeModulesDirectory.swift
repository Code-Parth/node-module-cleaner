//
//  NodeModulesDirectroy.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import Foundation

struct NodeModulesDirectory: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let size: Int64
    var isSelected: Bool = false
    
    var displayPath: String {
        let homePath = FileManager.default.homeDirectoryForCurrentUser.path
        return path.replacingOccurrences(of: homePath, with: "~")
    }
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    static func == (lhs: NodeModulesDirectory, rhs: NodeModulesDirectory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Helper for formatting byte counts
extension ByteCountFormatter {
    static func string(fromByteCount byteCount: Int64, countStyle: ByteCountFormatter.CountStyle) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = countStyle
        return formatter.string(fromByteCount: byteCount)
    }
}

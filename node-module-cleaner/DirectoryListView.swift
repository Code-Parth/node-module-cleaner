//
//  DirectoryListView.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

struct DirectoryListView: View {
    let directories: [NodeModulesDirectory]
    let toggleSelection: (NodeModulesDirectory) -> Void
    
    var body: some View {
        List {
            ForEach(directories) { directory in
                DirectoryRow(directory: directory, toggleSelection: toggleSelection)
            }
        }
        .listStyle(InsetListStyle())
    }
}

struct DirectoryRow: View {
    let directory: NodeModulesDirectory
    let toggleSelection: (NodeModulesDirectory) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: directory.isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(directory.isSelected ? .blue : .gray)
                .onTapGesture {
                    toggleSelection(directory)
                }
            
            VStack(alignment: .leading) {
                Text(directory.displayPath)
                    .font(.headline)
                
                Text("Project: \(projectNameFromPath(directory.path))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(directory.formattedSize)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelection(directory)
        }
    }
    
    private func projectNameFromPath(_ path: String) -> String {
        let components = path.split(separator: "/")
        if let nodeModulesIndex = components.firstIndex(where: { $0 == "node_modules" }),
           nodeModulesIndex > 0 {
            return String(components[nodeModulesIndex - 1])
        }
        return "Unknown"
    }
}

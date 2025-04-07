//
//  ContentView.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var scannerModel = ScannerModel()
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showingDeleteConfirmation = false
    @State private var deletionResult: (count: Int, size: Int64)? = nil
    @State private var showingDeletionResult = false
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    scannerModel.startScan(withSettings: appSettings)
                }) {
                    Label("Start Scan", systemImage: "magnifyingglass")
                }
                .disabled(scannerModel.isScanning)
                
                Divider()
                
                Button(action: { scannerModel.selectAll() }) {
                    Label("Select All", systemImage: "checkmark.circle")
                }
                .disabled(scannerModel.directories.isEmpty)
                
                Button(action: { scannerModel.deselectAll() }) {
                    Label("Deselect All", systemImage: "circle")
                }
                .disabled(scannerModel.directories.isEmpty)
                
                Divider()
                
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("Delete Selected", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .disabled(scannerModel.selectedCount == 0)
                
                Divider()
                
                Text("Sort by:")
                Picker("", selection: $appSettings.sortBy) {
                    ForEach(AppSettings.SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("", selection: $appSettings.sortOrder) {
                    ForEach(AppSettings.SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            if scannerModel.isScanning {
                ScanProgressView(
                    progress: scannerModel.scanProgress,
                    currentPath: scannerModel.currentScanningPath
                )
            } else if scannerModel.directories.isEmpty {
                WelcomeView()
            } else {
                DirectoryListView(
                    directories: getSortedDirectories(),
                    toggleSelection: { scannerModel.toggleSelection(for: $0) }
                )
            }
        }
        .navigationTitle("Node Modules Cleaner")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Label("Toggle Sidebar", systemImage: "sidebar.left")
                }
            }
            
            if !scannerModel.directories.isEmpty {
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Text("Selected: \(scannerModel.selectedCount) (\(scannerModel.formattedSelectedSize))")
                            .font(.caption)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StartScan"))) { _ in
            scannerModel.startScan(withSettings: appSettings)
        }
        .alert("Confirm Deletion", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                scannerModel.deleteSelectedDirectories { count, size in
                    deletionResult = (count, size)
                    showingDeletionResult = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(scannerModel.selectedCount) node_modules directories? This will free up \(scannerModel.formattedSelectedSize) of disk space.")
        }
        .alert("Deletion Complete", isPresented: $showingDeletionResult) {
            Button("OK", role: .cancel) {}
        } message: {
            if let result = deletionResult {
                Text("Successfully deleted \(result.count) directories and freed up \(ByteCountFormatter.string(fromByteCount: result.size, countStyle: .file)) of disk space.")
            } else {
                Text("Deletion completed.")
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func getSortedDirectories() -> [NodeModulesDirectory] {
        var sorted = scannerModel.directories
        
        switch appSettings.sortBy {
        case .size:
            sorted.sort { dir1, dir2 in
                appSettings.sortOrder == .descending ? dir1.size > dir2.size : dir1.size < dir2.size
            }
        case .path:
            sorted.sort { dir1, dir2 in
                let result = dir1.path.compare(dir2.path)
                return appSettings.sortOrder == .descending ? result == .orderedDescending : result == .orderedAscending
            }
        }
        
        return sorted
    }
}

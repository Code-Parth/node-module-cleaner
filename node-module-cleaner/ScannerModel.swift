//
//  ScannerModel.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import Foundation
import SwiftUI
import AppKit

class ScannerModel: ObservableObject {
    @Published var directories: [NodeModulesDirectory] = []
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var currentScanningPath: String = ""
    @Published var totalDirectoriesFound: Int = 0
    
    func startScan(withSettings settings: AppSettings) {
        isScanning = true
        directories = []
        scanProgress = 0.0
        totalDirectoriesFound = 0
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Select Your Home Directory"
        openPanel.message = "Please select your home directory to scan for node_modules folders"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.url {
                let path = url.path
                print("Selected directory: \(path)")
                
                let excludedFolders = getExcludedFolders(settings)
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.scanForNodeModules(startingAt: path, excludedFolders: excludedFolders, scanHidden: settings.scanHiddenFolders)
                }
            }
        } else {
            // User cancelled
            DispatchQueue.main.async {
                self.isScanning = false
            }
        }
    }
    
    private func getExcludedFolders(_ settings: AppSettings) -> [String] {
        var excluded: [String] = []
        
        if !settings.scanLibraryFolder { excluded.append("Library") }
        if !settings.scanDocumentsFolder { excluded.append("Documents") }
        if !settings.scanDownloadsFolder { excluded.append("Downloads") }
        if !settings.scanApplicationsFolder { excluded.append("Applications") }
        if !settings.scanMusicFolder { excluded.append("Music") }
        if !settings.scanMoviesFolder { excluded.append("Movies") }
        if !settings.scanPicturesFolder { excluded.append("Pictures") }
        
        return excluded
    }
    
    private func scanForNodeModules(startingAt startPath: String, excludedFolders: [String], scanHidden: Bool) {
        var nodeModulesPaths: [String] = []
        
        // Get first level directories
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(atPath: startPath) else {
            DispatchQueue.main.async { [weak self] in
                self?.isScanning = false
            }
            return
        }
        
        // Filter subdirectories
        let subDirs = contents.filter { item in
            let fullPath = (startPath as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir), isDir.boolValue else {
                return false
            }
            
            // Check if it's excluded
            if excludedFolders.contains(item) {
                return false
            }
            
            // Check if it's hidden and we should skip it
            if !scanHidden && item.hasPrefix(".") {
                return false
            }
            
            return true
        }
        
        let totalSubDirs = subDirs.count
        
        // Process each subdirectory
        for (index, subDir) in subDirs.enumerated() {
            let fullPath = (startPath as NSString).appendingPathComponent(subDir)
            
            DispatchQueue.main.async { [weak self] in
                self?.currentScanningPath = subDir
                self?.scanProgress = Double(index) / Double(totalSubDirs)
            }
            
            // Find node_modules
            findNodeModules(in: fullPath, result: &nodeModulesPaths)
        }
        
        // Process results
        var results: [NodeModulesDirectory] = []
        for path in nodeModulesPaths {
            if let size = directorySize(path) {
                let directory = NodeModulesDirectory(path: path, size: size)
                results.append(directory)
            }
        }
        
        // Sort by size (descending)
        results.sort { $0.size > $1.size }
        
        DispatchQueue.main.async { [weak self] in
            self?.directories = results
            self?.totalDirectoriesFound = results.count
            self?.isScanning = false
            self?.scanProgress = 1.0
        }
    }
    
    private func findNodeModules(in directory: String, result: inout [String]) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directory),
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
        
        while let url = enumerator?.nextObject() as? URL {
            // Skip further traversal if we found a node_modules directory
            if url.lastPathComponent == "node_modules" {
                if let values = try? url.resourceValues(forKeys: [.isDirectoryKey]),
                   let isDirectory = values.isDirectory, isDirectory {
                    result.append(url.path)
                    enumerator?.skipDescendants()
                }
            }
        }
    }
    
    private func directorySize(_ path: String) -> Int64? {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.fileSizeKey],
            options: []
        ) else {
            return nil
        }
        
        var size: Int64 = 0
        
        for case let url as URL in enumerator {
            guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                  let isRegularFile = values.isRegularFile,
                  isRegularFile,
                  let fileSize = values.fileSize else {
                continue
            }
            
            size += Int64(fileSize)
        }
        
        return size
    }
    
    func deleteSelectedDirectories(completion: @escaping (Int, Int64) -> Void) {
        let selectedDirectories = directories.filter { $0.isSelected }
        var deletedCount = 0
        var totalFreedSpace: Int64 = 0
        
        let dispatchGroup = DispatchGroup()
        
        for directory in selectedDirectories {
            dispatchGroup.enter()
            
            DispatchQueue.global(qos: .userInitiated).async {
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(atPath: directory.path)
                    deletedCount += 1
                    totalFreedSpace += directory.size
                } catch {
                    print("Failed to delete \(directory.path): \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Update the directories list by removing deleted ones
            self?.directories.removeAll(where: { $0.isSelected })
            completion(deletedCount, totalFreedSpace)
        }
    }
    
    func toggleSelection(for directory: NodeModulesDirectory) {
        if let index = directories.firstIndex(where: { $0.id == directory.id }) {
            directories[index].isSelected.toggle()
        }
    }
    
    func selectAll() {
        for i in 0..<directories.count {
            directories[i].isSelected = true
        }
    }
    
    func deselectAll() {
        for i in 0..<directories.count {
            directories[i].isSelected = false
        }
    }
    
    var selectedCount: Int {
        directories.filter { $0.isSelected }.count
    }
    
    var selectedSize: Int64 {
        directories.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }
    
    var formattedSelectedSize: String {
        ByteCountFormatter.string(fromByteCount: selectedSize, countStyle: .file)
    }
}

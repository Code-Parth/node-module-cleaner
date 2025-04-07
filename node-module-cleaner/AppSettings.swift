//
//  AppSettings.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

class AppSettings: ObservableObject {
    @Published var scanLibraryFolder: Bool = false
    @Published var scanDocumentsFolder: Bool = false
    @Published var scanDownloadsFolder: Bool = false
    @Published var scanApplicationsFolder: Bool = false
    @Published var scanMusicFolder: Bool = false
    @Published var scanMoviesFolder: Bool = false
    @Published var scanPicturesFolder: Bool = false
    @Published var scanHiddenFolders: Bool = false
    @Published var sortBy: SortOption = .size
    @Published var sortOrder: SortOrder = .descending
    
    enum SortOption: String, CaseIterable, Identifiable {
        case size = "Size"
        case path = "Path"
        
        var id: String { self.rawValue }
    }
    
    enum SortOrder: String, CaseIterable, Identifiable {
        case ascending = "Ascending"
        case descending = "Descending"
        
        var id: String { self.rawValue }
    }
}

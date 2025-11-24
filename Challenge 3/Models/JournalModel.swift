//
//  JournalModel.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 18/11/25.
//
import Foundation
import SwiftUI
import SwiftData

@Model
class Journal: Identifiable{
    var id = UUID()
    var plantID: UUID
    var entries: [JournalEntry]
    init(id: UUID = UUID(), plantID: UUID, entries: [JournalEntry]) {
        self.id = id
        self.plantID = plantID
        self.entries = entries
    }
    
}

@Model
class JournalEntry: Identifiable{
    var id = UUID()
    var date: Date
    var notes: String?
    var photoData: Data?
    init(id: UUID = UUID(), date: Date, notes: String?, photoData: Data?) {
        self.id = id
        self.date = date
        self.notes = notes
        self.photoData = photoData
    }
}


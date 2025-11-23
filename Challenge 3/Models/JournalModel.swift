//
//  JournalModel.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 18/11/25.
//
import Foundation
import SwiftUI

struct Journal: Identifiable{
    var id = UUID()
    var plantID: UUID
    var entries: [JournalEntry]
}

struct JournalEntry: Identifiable{
    var id = UUID()
    var date: Date
    var notes: String?
    var photo: Image?
}

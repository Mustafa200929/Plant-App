//
//  JournalVM.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 18/11/25.
//
import Foundation
import Combine
import SwiftUI

class JournalViewModel: ObservableObject {
    @Published var journals: [Journal] = []
    
    func addJournalEntry(plantID: UUID, notes: String?, photo: UIImage?) {
        ensureJournal(for: plantID)

        guard let jIndex = journals.firstIndex(where: { $0.plantID == plantID }) else { return }

        let entry = JournalEntry(date: Date(),
                                 notes: notes,
                                 photo: photo.map { Image(uiImage: $0) })

        journals[jIndex].entries.insert(entry, at: 0)  // NEWEST FIRST
    }
    
    func ensureJournal(for plantID: UUID) {
        if journals.contains(where: { $0.plantID == plantID }) {
            return
        }
        let new = Journal(plantID: plantID, entries: [])
        journals.append(new)
    }
    
    func returnJournal(for plantID: UUID) -> Journal {
        ensureJournal(for: plantID)
        if let journal = journals.first(where: { $0.plantID == plantID }) {
            return journal
        }
        let new = Journal(plantID: plantID, entries: [])
        journals.append(new)
        return new
    }

    
}

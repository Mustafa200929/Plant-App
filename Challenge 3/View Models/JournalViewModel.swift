//
//  JournalVM.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 18/11/25.
//
import Foundation
import Combine
import SwiftUI
import SwiftData


class JournalViewModel: ObservableObject {
    @Published var journals: [Journal] = []
    
    func addJournalEntry(plantID: UUID, notes: String?, photo: UIImage?, context: ModelContext) {
        let journal = fetchJournal(context: context, id: plantID)
        let entry = JournalEntry(date: Date(),
                                 notes: notes,
                                 photoData: convertUIImageToData(photo: photo))
        journal.entries.insert(entry, at: 0)
    }
    
    func fetchJournal(context: ModelContext, id: UUID)-> Journal {
        let descriptor = FetchDescriptor<Journal>(predicate: #Predicate{$0.plantID == id})
        if let journal = try? context.fetch(descriptor).first{
            return journal
        }
        let new = Journal(plantID: id, entries: [])
        context.insert(new)
        return new
    }
    
    func convertUIImageToData(photo: UIImage?)->Data?{
        return photo?.jpegData(compressionQuality: 1)
    }
    
    func convertDataToSwiftUIimage(data: Data?)->Image?{
        if let data = data {
           if let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
           }else{return nil}
        }else{return nil}
    }
    
    func deleteJournal(for plantID: UUID) {
        if let idx = journals.firstIndex(where: { $0.plantID == plantID }) {
            journals.remove(at: idx)
        }
    }

    
}

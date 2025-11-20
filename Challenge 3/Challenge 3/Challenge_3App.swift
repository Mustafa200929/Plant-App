//
//  Challenge_3App.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 15/11/25.
//

import SwiftUI

@main
struct Challenge_3App: App {
    @AppStorage("hasFinishedStory") var hasFinishedStory = false
    @StateObject var plantVM = PlantViewModel()
    @StateObject var journalVM = JournalViewModel()
    var body: some Scene {
        WindowGroup {
            if hasFinishedStory {
                HomeView()
                    .environmentObject(PlantViewModel())
                    .environmentObject(JournalViewModel())
            } else {
                StoryFlow()
                    .environmentObject(PlantViewModel())
                    .environmentObject(JournalViewModel())
            }
        }
    }
}


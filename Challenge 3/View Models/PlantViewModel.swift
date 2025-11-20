//
//  PlantViewModel.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on ___
//

import SwiftUI
import Combine
import FoundationModels

@MainActor
class PlantViewModel: ObservableObject {

    @Published var plants: [Plant] = []
    @Published var tipsForSpecies: [String : [String]] = [:]

    // FM service for generating germination tips
    private let tipGenerator = TipGenerator()

    func addPlant(plantName: String,
                  plantType: String,
                  plantIconName: String)
    {
        let newPlant = Plant(
            plantName: plantName,
            plantType: plantType,
            plantIconName: plantIconName,
            plantDateCreated: Date()
        )
        plants.append(newPlant)
    }
    func removePlant(at index: Int) {
        guard plants.indices.contains(index) else { return }
        plants.remove(at: index)
    }

    func plantAge(index: Int) -> Int {
        let today = Date()
        let created = plants[index].plantDateCreated

        return Calendar.current.dateComponents([.day],
                                               from: created,
                                               to: today).day ?? 0
    }
    
    func findPlantData(plantType: String) -> PlantInfo? {
        let key = plantType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return PlantDatabase.first { $0.name.lowercased() == key }
    }

    func loadTips(for plantInfo: PlantInfo) async {

        let speciesKey = plantInfo.name.lowercased()

        // If we already generated tips for this species, don't regenerate.
        if tipsForSpecies[speciesKey] != nil {
            return
        }

        do {
            let fmTips = try await tipGenerator.generateTips(for: plantInfo)
            tipsForSpecies[speciesKey] = fmTips
        } catch {
            print("❌ FM Tips Error: \(error)")
        }
    }

    func tips(for plantInfo: PlantInfo) -> [String] {
        let key = plantInfo.name.lowercased()
        return tipsForSpecies[key] ?? []
    }
}


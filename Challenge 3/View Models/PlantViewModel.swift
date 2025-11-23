//
//  PlantViewModel.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on ___
//

import SwiftUI
import SwiftData
import Combine
import FoundationModels
import CoreGraphics


class PlantViewModel: ObservableObject {
    @Published var tipsForSpecies: [String : [String]] = [:]
    @Published var islandSize: CGSize = CGSize(width: 340, height: 400)
    private let tipGenerator = TipGenerator()
    
    func addPlant(plantName: String, plantType: String, plantIconName: String, context: ModelContext, plants: [Plant]){
        let newPlant = Plant(
            plantName: plantName,
            plantType: plantType,
            plantIconName: plantIconName,
            plantDateCreated: Date(),
            plantDateGerminated: Date(),
            plantIsGerminated: false
        )
        if islandSize != .zero {
            let islandSize = CGSize(width: 340, height: 400)
            let baseSize: CGFloat = 90
            let count = plants.count
            let scale = max(0.5, min(1.0, 3.0 / CGFloat(max(count, 1))))
            let itemSize = baseSize * scale
            let p = assignRandomPosition(in: islandSize, plants: plants, itemSize: itemSize)
            newPlant.positionX = p.x
            newPlant.positionY = p.y
        }
        context.insert(newPlant)
    }
    
    func removePlant(plant: Plant, context: ModelContext) {
        context.delete(plant)
    }
    
    func plantAge(plant: Plant) -> Int {
        let today = Date()
        let created = plant.plantDateCreated
        return Calendar.current.dateComponents([.day],from: created,to: today).day ?? 0
    }
    
    func findPlantData(plantType: String) -> PlantInfo? {
        let key = plantType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return PlantDatabase.first { $0.name.lowercased() == key }
    }
    
    func loadTips(for plantInfo: PlantInfo) async {
        let speciesKey = plantInfo.name.lowercased()
        if tipsForSpecies[speciesKey] != nil {return}
        do{let fmTips = try await tipGenerator.generateTips(for: plantInfo)
            tipsForSpecies[speciesKey] = fmTips
        } catch {print("FM Tips Error: \(error)")}
    }
    
    func plantIsGerminated(plant: Plant) {
        plant.plantIsGerminated = true
        plant.plantDateGerminated = Date()
    }
    
    
    func tips(for plantInfo: PlantInfo) -> [String] {
        let key = plantInfo.name.lowercased()
        return tipsForSpecies[key] ?? []
    }

    func assignRandomPosition(in size: CGSize, plants: [Plant], itemSize: CGFloat) -> CGPoint {
        let radius = islandSize.width / 2
        let innerRadius = radius - itemSize/2
        let center = CGPoint(x: radius, y: radius)
        let minimumGap: CGFloat = itemSize * 0.45
        let maxAttempts = 200
        for _ in 0..<maxAttempts {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 0...innerRadius)

            let candidate = CGPoint(
                x: center.x + cos(angle) * dist,
                y: center.y + sin(angle) * dist
            )
            let overlapping = plants.contains { existing in
                let dx = existing.position.x - candidate.x
                let dy = existing.position.y - candidate.y
                return sqrt(dx*dx + dy*dy) < (itemSize + minimumGap)
            }
            if !overlapping {
                return candidate
            }
        }
        return center
    }

}

//
//  PlantViewModel.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on ___
//

import SwiftUI
import Combine
import FoundationModels
import CoreGraphics
@MainActor
class PlantViewModel: ObservableObject {
    
    @Published var plants: [Plant] = []
    @Published var tipsForSpecies: [String : [String]] = [:]
    @Published var islandSize: CGSize = .zero
    @Published var positions: [UUID : CGPoint] = [:]
    
    private let tipGenerator = TipGenerator()
    
    func addPlant(plantName: String, plantType: String, plantIconName: String){
        var newPlant = Plant(
            plantName: plantName,
            plantType: plantType,
            plantIconName: plantIconName,
            plantDateCreated: Date(),
            plantDateGerminated: Date(),
            plantIsGerminated: false
        )
        if islandSize != .zero {
            newPlant.position = assignRandomPosition(in: islandSize)
        }
        
        plants.append(newPlant)
    }
    
    func removePlant(plant: Plant) {
        plants.removeAll { $0.id == plant.id }
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
        guard let index = plants.firstIndex(where: { $0.id == plant.id}) else {
            return
        }
        var updated = plants[index]
        updated.plantIsGerminated = true
        updated.plantDateGerminated = Date()
        plants[index] = updated
    }
    
    
    func tips(for plantInfo: PlantInfo) -> [String] {
        let key = plantInfo.name.lowercased()
        return tipsForSpecies[key] ?? []
    }
    
    func assignRandomPosition(in size: CGSize) -> CGPoint {
        let radius: CGFloat = 50 // temp radius, real size is scaled later
        var newPoint: CGPoint
        var attempts = 0
        repeat {
            attempts += 1
            newPoint = CGPoint(
                x: CGFloat.random(in: 60...(size.width - 60)),
                y: CGFloat.random(in: 60...(size.height - 60))
            )
            let overlap = plants.contains { existing in
                let dx = existing.position.x - newPoint.x
                let dy = existing.position.y - newPoint.y
                return sqrt(dx*dx + dy*dy) < (radius * 2)
            }
            if !overlap {return newPoint}
        } while attempts < 50
        return newPoint
    }
    
    func randomPositionAvoidingOverlap(islandSize: CGSize,itemSize: CGFloat,plantID: UUID) -> CGPoint {
        let radius = islandSize.width / 2
        let innerRadius = radius - itemSize/2
        let center = CGPoint(x: radius, y: radius)
        let minimumGap: CGFloat = itemSize * 0.35
        let maxAttempts = 200
        for _ in 0..<maxAttempts {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 0...innerRadius)
            let candidate = CGPoint(
                x: center.x + cos(angle) * dist,
                y: center.y + sin(angle) * dist
            )
            let collision = positions.values.contains { existing in
                hypot(existing.x - candidate.x, existing.y - candidate.y)
                < (itemSize + minimumGap)
            }
            if !collision {
                positions[plantID] = candidate
                return candidate
            }
        }
        let fallback = center
        positions[plantID] = fallback
        return fallback
    }
}

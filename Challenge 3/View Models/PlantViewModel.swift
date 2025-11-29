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
    @Published var islandSize: CGSize = CGSize(width: 340, height: 480)
    private let tipGenerator = TipGenerator()
    
    func addPlant(plantName: String, plantType: String, plantIconName: String, context: ModelContext, plants: [Plant]){
        let newPlant = Plant(
            plantName: plantName,
            plantType: plantType,
            plantIconName: plantIconName,
            plantDateCreated: Date(),
            plantDateGerminated: Date(),
            plantIsGerminated: false,
            plantShouldHaveGerminated: false
        )
        if islandSize != .zero {
            
            let baseSize: CGFloat = 90
            let count = plants.count
            let scale = max(0.5, min(1.0, 3.0 / CGFloat(max(count, 1))))
            let itemSize = baseSize * scale
            let p = assignRandomPosition(in: islandSize, plants: plants, itemSize: itemSize)
            newPlant.positionX = p.x
            newPlant.positionY = p.y
        }
        context.insert(newPlant)
        try? context.save()
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
    func assignRandomPosition(in size: CGSize, plants: [Plant], itemSize: CGFloat, textHeight: CGFloat = 20) -> CGPoint {
        let maxAttempts = 1000
        let padding: CGFloat = 10
        let rx = (size.width / 2) - padding - itemSize / 2
        let ry = (size.height / 2) - padding - itemSize / 2 - textHeight / 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        for _ in 0..<maxAttempts {
            let angle = CGFloat.random(in: 0..<(2 * .pi))
            let r = sqrt(CGFloat.random(in: 0...1))
            let x = center.x + r * rx * cos(angle)
            let y = center.y + r * ry * sin(angle)
            
            let candidateRect = CGRect(x: x - itemSize/2, y: y - itemSize/2, width: itemSize, height: itemSize + textHeight)
            
            let overlapping = plants.contains { other in
                let otherRect = CGRect(
                    x: other.positionX - itemSize/2,
                    y: other.positionY - itemSize/2,
                    width: itemSize,
                    height: itemSize + textHeight
                )
                return candidateRect.intersects(otherRect)
            }
            
            if !overlapping {
                return CGPoint(x: x, y: y)
            }
        }
        
        return center
    }



}

//
//  nonaitipgenerator.swift
//  Challenge 3
import Foundation

struct NonAITipGenerator {
    static func tips(for info: PlantInfo) -> [String] {
        var tips: [String] = []

        tips.append("Watering: \(info.wateringperiod)")
        tips.append("Lighting: \(info.lighting)")
        tips.append("Soil: \(info.soilcond)")
        tips.append("Temperature: \(info.temp) °C")
        tips.append("Fertiliser: Use \(info.ferttype), apply \(info.fertfreq)")
        tips.append("Flowering: \(info.flowering) — \(info.cond)")
        tips.append("Toxicity: \(info.toxicinfo)")

        return tips
    }
}

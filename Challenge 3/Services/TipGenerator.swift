//
//  TipGenerator.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 20/11/25.
//

import FoundationModels
import SwiftUI
import Combine

class TipGenerator: ObservableObject {
    let session = LanguageModelSession(model: .default)

    func generateTips(for plant: PlantInfo) async throws -> [String] {

        let prompt = """
                You are a plant germination specialist.

                Generate EXACTLY 4 short actionable germination tips (max 15 words each)
                specifically for the **germination stage only**, not general plant care. Your goal is to help succesful germimation.

                Use this data:
                Name: \(plant.name)
                Germination Time: \(plant.germination)
                Temperature: \(plant.temp)
                Soil: \(plant.soilcond)
                Watering During Germination: \(plant.wateringperiod)
                Lighting: \(plant.lighting)
                Special Conditions: \(plant.specialcond)

                Output ONLY the 4 tips, one per line, NO numbering, NO symbols, NO extra text.
                """



        // This returns LanguageModelSession.Response<String>
        let result = try await session.respond(to: prompt)

        // Extract actual text
        let text: String = result.content
        print("RAW OUTPUT:\n\(text)")

        // Split into separate lines
        let rawLines = text.components(separatedBy: CharacterSet.newlines)

        // Trim + remove empty rows
        let lines = rawLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Remove numbering like "1. " or "2) "
        let cleaned = lines.map { line in
            line.replacingOccurrences(
                of: #"^\d+[\.\)]\s*"#,
                with: "",
                options: .regularExpression
            )
        }

        return cleaned
    }
}

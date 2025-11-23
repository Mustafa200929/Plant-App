//
//  PlantModal.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 17/11/25.
//
import Foundation
import CoreGraphics
import SwiftData

@Model
class Plant: Identifiable {
    var id = UUID()
    var plantName: String
    var plantType: String
    var plantIconName: String
    var plantDateCreated: Date
    var plantDateGerminated: Date
    var plantIsGerminated: Bool
    var positionX: Double
    var positionY: Double
    var position: CGPoint{
        CGPoint(x: positionX, y: positionY)
    }
    
    init(id: UUID = UUID(), plantName: String, plantType: String, plantIconName: String, plantDateCreated: Date, plantDateGerminated: Date, plantIsGerminated: Bool, positionX: Double = .zero, positionY: Double = .zero) {
        self.id = id
        self.plantName = plantName
        self.plantType = plantType
        self.plantIconName = plantIconName
        self.plantDateCreated = plantDateCreated
        self.plantDateGerminated = plantDateGerminated
        self.plantIsGerminated = plantIsGerminated
        self.positionX = positionX
        self.positionY = positionY
    }
}

struct PlantTip: Identifiable {
    var id = UUID()
    var symbol: String
    var text: String
}

struct PlantInfo: Identifiable {
    let id = UUID()
    let name: String
    let germination: String
    let germinationMaxDays: Int
    let temp: String
    let specialcond: String
    let soilcond: String
    let wateringperiod: String
    let lighting: String
    let age: String
    let ferttype: String
    let fertfreq: String
    let flowering: String
    let cond: String
    let toxicinfo: String
}

let PlantDatabase: [PlantInfo] = [
    PlantInfo(
            name: "Aloe Vera",
            germination: "2-4 weeks",
            germinationMaxDays: 21,
            temp: "13-27",
            specialcond: "dry germinations from pods that have split open, or either buy online",
            soilcond: "Well-draining potting mix with perlite or sand",
            wateringperiod: "Water deeply but let soil dry between waterings",
            lighting: "Bright, indirect sunlight",
            age: "2-3 years",
            ferttype: "diluted, balanced liquid fertilizer",
            fertfreq: "once a month indoor, once a year outdoors",
            flowering: "3 to 5 years old",
            cond: "uncommon to bloom indoors",
            toxicinfo: "Latex layer is toxic"
        ),

        PlantInfo(
            name: "Basil",
            germination: "5 to 10 days",
            germinationMaxDays: 10,
            temp: "21-26",
            specialcond: "wait for the soilcond's flower pods to dry and turn brown before harvesting the germinations",
            soilcond: "Moist, well-draining soil",
            wateringperiod: "Keep soil moist but not waterlogged",
            lighting: "Full sun (6-8 hours)",
            age: "60-90 days",
            ferttype: "balanced fertilizer",
            fertfreq: "3-4 weeks indoor, 4-6 weeks outdoor",
            flowering: "6 weeks after sprouting",
            cond: "6 hours of sunlight a day to be able to bloom indoors",
            toxicinfo: "Non Toxic"
        ),

        PlantInfo(
            name: "Cactus",
            germination: "5-14 days",
            germinationMaxDays: 60,
            temp: "20-30",
            specialcond: "clean them by separating them from pulp and debris",
            soilcond: "Cactus/succulent mix (sandy, very well-draining)",
            wateringperiod: "Very little water — let soil fully dry",
            lighting: "Bright direct sunlight",
            age: "3-4 years old",
            ferttype: "Cactus specific fertiliser",
            fertfreq: "once or twice during spring/summer",
            flowering: "during spring/summer",
            cond: "bright light is required to bloom indoors",
            toxicinfo: "Some cactus are edible and produce fruits; however some are toxic"
        ),

        PlantInfo(
            name: "Jade plant",
            germination: "2-5 weeks",
            germinationMaxDays: 24,
            temp: "18 to 24",
            specialcond: "Very challenging to germinate and use germinations like beans",
            soilcond: "Sandy, dry, well-draining soil",
            wateringperiod: "every 4-6 weeks only during summer and spring",
            lighting: "Bright light or partial sun",
            age: "3-4 years old",
            ferttype: "slow released balanced fertiliser",
            fertfreq: "1-2 times a month",
            flowering: "late winter to early spring",
            cond: "Rarely bloom as an indoor soilcond",
            toxicinfo: "Some are toxic to cats, dogs and babies"
        ),

        PlantInfo(
            name: "Rubber plant",
            germination: "3-5 weeks",
            germinationMaxDays: 21,
            temp: "18 to 25",
            specialcond: "Soak in warm water for 24 hours beforehand",
            soilcond: "A well draining mix",
            wateringperiod: "1-2 times in a week",
            lighting: "bright indirect",
            age: "Several Years",
            ferttype: "A household indoor plant balanced fertiliser",
            fertfreq: "every 2-4 only in summer and spring",
            flowering: "rare condition",
            cond: "When flowered, you might not be able to spot them immediately",
            toxicinfo: "Most are toxic to cats, dogs and humans"
        ),

        PlantInfo(
            name: "Water spinach",
            germination: "1-2 weeks",
            germinationMaxDays: 7,
            temp: "25-30",
            specialcond: "Recommended to soak the seeds for up to 24 hours but 8-10 should be sufficient",
            soilcond: "Coco coir mixed with compost",
            wateringperiod: "once every 2 days",
            lighting: "Direct sunlight",
            age: ">40 days",
            ferttype: "High nitrogen fertilisers",
            fertfreq: "Every 2 weeks after germination",
            flowering: "Summer to autumn",
            cond: "Stop harvesting for a while",
            toxicinfo: "Edible and can be used in cooking. May be fed to cats and dogs but it’s up to the user's discretion"
        ),

        PlantInfo(
            name: "Spider plant",
            germination: "2-3 weeks",
            germinationMaxDays: 21,
            temp: "23 to 27",
            specialcond: "None",
            soilcond: "Africa violet or soilless potting mixture",
            wateringperiod: "1 week in spring/summer, 2 weeks in winter/autumn",
            lighting: "bright and indirect",
            age: "When its roots have grown well",
            ferttype: "Balanced fertiliser",
            fertfreq: "every 2-4 weeks only in summer and spring",
            flowering: "anytime",
            cond: "Slightly root-bound",
            toxicinfo: "No, unless overconsumed"
        ),

        PlantInfo(
            name: "Snake plant",
            germination: "4-6 weeks",
            germinationMaxDays: 45,
            temp: "24 to 27",
            specialcond: "None",
            soilcond: "1:1 cactus mix and perlite",
            wateringperiod: "1 week in summer and spring, 2 weeks in winter and autumn",
            lighting: "bright indirect",
            age: "2 years in the same pot",
            ferttype: "10-10-10 Houseplant fertiliser",
            fertfreq: "Every 2 months",
            flowering: "once a year",
            cond: "Avoid repotting and keep temperatures fluctuating",
            toxicinfo: "Toxic to cats and dogs"
        )
]


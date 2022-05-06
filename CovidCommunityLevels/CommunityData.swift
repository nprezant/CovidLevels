//
//  CommunityData.swift
//  CovidCommunityLevels
//
//  Created by Noah on 5/6/22.
//

import Foundation
import SwiftUI

struct CommunityData : Identifiable {
    var id = UUID() // Each instance will be uniquely identifiable
    
    var level: String
    var dateUpdated: Date
    var county: String
    var countyPopulation: Int
    var state: String
    var casesPer100k: Double
    var hospitalAdmissionsPer100k: Double
    var healthServiceArea: String
    var healthServiceAreaPopulation: Int
    var historical: [CommunityData] = []
}

fileprivate func LarimerData(level: String, dateUpdated: Date, historical: [CommunityData] = []) -> CommunityData {
    return CommunityData(level: level, dateUpdated: dateUpdated, county: "Larimer County", countyPopulation: 356899, state: "Colorado", casesPer100k: 103.95, hospitalAdmissionsPer100k: 6.2, healthServiceArea: "Larimer, CO", healthServiceAreaPopulation: 356899, historical: historical)
}

extension CommunityData {
    static var exampleData: [CommunityData] {
        [
            LarimerData(
                level: "Low",
                dateUpdated: Date.now,
                historical:
                    [
                        LarimerData(level: "Low", dateUpdated: Date.now.addingTimeInterval(-60*60*24*7)),
                        LarimerData(level: "Med", dateUpdated: Date.now.addingTimeInterval(-60*60*24*7*2)),
                        LarimerData(level: "High", dateUpdated: Date.now.addingTimeInterval(-60*60*24*7*3)),
                    ])
        ]
    }
}

extension CommunityData {
    func levelColor() -> Color {
        switch level.lowercased() {
        case "low":
            return Color(hex: 0x90ee90)
        case "med":
            return Color(hex: 0xfffdaf)
        case "high":
            return Color(hex: 0xff7f7f)
        default:
            return Color.gray
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}


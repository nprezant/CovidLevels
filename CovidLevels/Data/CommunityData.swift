//
//  CommunityData.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import Foundation
import SwiftUI

struct TransmissionData : Identifiable {
    // Data source: https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-County-Level-of-Community-T/8396-v7yb
    // Updated daily
    var id = UUID() // Each instance will be uniquely identifiable
    var level: String // Options: low, moderate, substantial, high, blank
    var state: String
    var county: String
    var countyFips: String // Zero padded
    var date: Date
    var percentPositiveTestsLast7Days: Double
    var newCasesPer100kLast7Days: Double? // May be "suppressed" if number is low but non-zero
    var historical: [TransmissionData] = []
    
    func levelColor() -> Color {
        return CovidLevels.levelColor(level: level)
    }
}

struct CommunityData : Identifiable {
    // Data source: https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-Community-Levels-by-County/3nnm-4jni
    // Updated weekly
    var id = UUID() // Each instance will be uniquely identifiable
    var level: String // Options: Low, Medium, High
    var dateUpdated: Date
    var county: String
    var countyFips: String // Zero padded
    var countyPopulation: Int
    var state: String
    var healthServiceArea: String
    var healthServiceAreaNumber: Int
    var healthServiceAreaPopulation: Int
    var covidCasesPer100k: Double // 7 day total
    var covidHospitalAdmissionsPer100k: Double // 7 day total
    var covidInpatientBedUtilization: Double // Percent of staffed inpatient beds occupied by COVID-19 patients (7 day average)
    var historical: [CommunityData] = []
    
    func levelColor() -> Color {
        return CovidLevels.levelColor(level: level)
    }
}

fileprivate func LarimerTransmissionData(level: String, dateUpdated: Date, historical: [TransmissionData] = []) -> TransmissionData {
    return TransmissionData(level: level, state: "Colorado", county: "Larimer County", countyFips: "08069", date: dateUpdated, percentPositiveTestsLast7Days: 7.79, newCasesPer100kLast7Days: 138.69, historical: historical)
}

extension TransmissionData {
    static var exampleData: [TransmissionData] {
        [
            LarimerTransmissionData(
                level: "Low",
                dateUpdated: Date.now,
                historical:
                    [
                        LarimerTransmissionData(level: "low", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(days: 1))),
                        LarimerTransmissionData(level: "substantial", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(days: 2))),
                        LarimerTransmissionData(level: "high", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(days: 3))),
                        LarimerTransmissionData(level: "moderate", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(days: 4))),
                    ])
        ]
    }
}

fileprivate func LarimerCommunityData(level: String, dateUpdated: Date, historical: [CommunityData] = []) -> CommunityData {
    return CommunityData(level: level, dateUpdated: dateUpdated, county: "Larimer County", countyFips: "08069", countyPopulation: 356899, state: "Colorado", healthServiceArea: "Larimer, CO", healthServiceAreaNumber: 796, healthServiceAreaPopulation: 356899, covidCasesPer100k: 233.96, covidHospitalAdmissionsPer100k: 11.5, covidInpatientBedUtilization: 5.7, historical: historical)
}

extension CommunityData {
    static var exampleData: [CommunityData] {
        [
            LarimerCommunityData(
                level: "Low",
                dateUpdated: Date.now,
                historical:
                    [
                        LarimerCommunityData(level: "Low", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 1))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 2))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 3))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 4))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 5))),
                        LarimerCommunityData(level: "High", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 6))),
                        LarimerCommunityData(level: "High", dateUpdated: Date.now.addingTimeInterval(-secondsInDays(weeks: 7))),
                    ])
        ]
    }
}

fileprivate func levelColor(level: String) -> Color {
    switch level.lowercased() {
    case "low":
        return Color(hex: 0x90ee90)
    case "med","moderate":
        return Color(hex: 0xfffdaf)
    case "substantial":
        return Color(hex: 0xff9d5c)
    case "high":
        return Color(hex: 0xff7f7f)
    default:
        return Color(hex: 0xd3d3d3)
    }
}

fileprivate func secondsInDays(days: Int) -> Double {
    return Double(60 * 60 * 24 * days)
}

fileprivate func secondsInDays(weeks: Int) -> Double {
    return secondsInDays(days: weeks * 7)
}

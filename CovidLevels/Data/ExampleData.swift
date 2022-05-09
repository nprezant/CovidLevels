//
//  ExampleData.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation

fileprivate func LarimerTransmissionData(level: String, dateUpdated: Date, historical: [TransmissionData] = []) -> TransmissionData {
    return TransmissionData(level: level, state: "Colorado", county: "Larimer County", countyFips: "08069", date: dateUpdated, percentPositiveTestsLast7Days: 7.79, newCasesPer100kLast7Days: 138.69, historical: historical)
}

fileprivate func LarimerCommunityData(level: String, dateUpdated: Date, historical: [CommunityData] = []) -> CommunityData {
    return CommunityData(level: level, dateUpdated: dateUpdated, county: "Larimer County", countyFips: "08069", countyPopulation: 356899, state: "Colorado", healthServiceArea: "Larimer, CO", healthServiceAreaNumber: 796, healthServiceAreaPopulation: 356899, covidCasesPer100k: 233.96, covidHospitalAdmissionsPer100k: 11.5, covidInpatientBedUtilization: 5.7, historical: historical)
}

fileprivate func secondsInDays(days: Int) -> Double {
    return Double(60 * 60 * 24 * days)
}

fileprivate func secondsInDays(weeks: Int) -> Double {
    return secondsInDays(days: weeks * 7)
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


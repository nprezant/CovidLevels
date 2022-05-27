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

extension TimeInterval {
    static func minutes(_ minutes: Int) -> TimeInterval {
        return TimeInterval(60 * minutes)
    }
    static func hours(_ hours: Int) -> TimeInterval {
        return minutes(60 * hours)
    }
    static func days(_ days: Int) -> TimeInterval {
        return hours(24 * days)
    }
    static func weeks(_ weeks: Int) -> TimeInterval {
        return days(7 * weeks)
    }
}

extension TransmissionData {
    static var exampleData: [TransmissionData] {
        [
            LarimerTransmissionData(
                level: "Low",
                dateUpdated: Date.today,
                historical:
                    [
                        LarimerTransmissionData(level: "low", dateUpdated: Date.today.addingTimeInterval(-.days(1))),
                        LarimerTransmissionData(level: "substantial", dateUpdated: Date.today.addingTimeInterval(-.days(2))),
                        LarimerTransmissionData(level: "high", dateUpdated: Date.today.addingTimeInterval(-.days(3))),
                        LarimerTransmissionData(level: "moderate", dateUpdated: Date.today.addingTimeInterval(-.days(4))),
                    ])
        ]
    }
}

extension CommunityData {
    static var exampleData: [CommunityData] {
        [
            LarimerCommunityData(
                level: "Low",
                dateUpdated: Date.today,
                historical:
                    [
                        LarimerCommunityData(level: "Low", dateUpdated: Date.today.addingTimeInterval(-.weeks(1))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.today.addingTimeInterval(-.weeks(2))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.today.addingTimeInterval(-.weeks(3))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.today.addingTimeInterval(-.weeks(4))),
                        LarimerCommunityData(level: "Med", dateUpdated: Date.today.addingTimeInterval(-.weeks(5))),
                        LarimerCommunityData(level: "High", dateUpdated: Date.today.addingTimeInterval(-.weeks(6))),
                        LarimerCommunityData(level: "High", dateUpdated: Date.today.addingTimeInterval(-.weeks(7))),
                    ])
        ]
    }
}


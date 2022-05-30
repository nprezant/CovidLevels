//
//  ExampleData.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation

fileprivate func LarimerTransmissionData(level: String, dateUpdated: Date, historical: [TransmissionData] = []) -> TransmissionData {
    var t = TransmissionData()
    t.level = level
    t.state = "Colorado"
    t.county = "Larimer County"
    t.countyFips = "08069"
    t.date = dateUpdated
    t.percentPositiveTestsLast7Days = 7.79
    t.newCasesPer100kLast7Days = 138.69
    t.historical = historical
    return t
}

fileprivate func LarimerCommunityData(level: String, dateUpdated: Date, historical: [CommunityData] = []) -> CommunityData {
    var c = CommunityData()
    c.level = level
    c.dateUpdated = dateUpdated
    c.county = "Larimer County"
    c.countyFips = "08069"
    c.countyPopulation = 356899
    c.state = "Colorado"
    c.healthServiceArea = "Larimer, CO"
    c.healthServiceAreaNumber = 796
    c.healthServiceAreaPopulation = 356899
    c.covidCasesPer100k = 233.96
    c.covidHospitalAdmissionsPer100k = 11.5
    c.covidInpatientBedUtilization = 5.7
    c.historical = historical
    return c
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


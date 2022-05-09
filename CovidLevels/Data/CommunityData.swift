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
    var level: String = "-" // Options: low, moderate, substantial, high, blank
    var state: String = "-"
    var county: String = "-"
    var countyFips: String = "-" // Zero padded
    var date: Date = Date.now
    var percentPositiveTestsLast7Days: Double = -1
    var newCasesPer100kLast7Days: Double? = nil // May be "suppressed" if number is low but non-zero
    var historical: [TransmissionData] = []
    
    func levelColor() -> Color {
        return CovidLevels.levelColor(level: level)
    }
}

struct CommunityData : Identifiable {
    // Data source: https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-Community-Levels-by-County/3nnm-4jni
    // Updated weekly
    var id = UUID() // Each instance will be uniquely identifiable
    var level: String = "-" // Options: Low, Medium, High
    var dateUpdated: Date = Date.now
    var county: String = "-"
    var countyFips: String = "-" // Zero padded
    var countyPopulation: Int = -1
    var state: String = "-"
    var healthServiceArea: String = "-"
    var healthServiceAreaNumber: Int = -1
    var healthServiceAreaPopulation: Int = -1
    var covidCasesPer100k: Double = -1 // 7 day total
    var covidHospitalAdmissionsPer100k: Double = -1 // 7 day total
    var covidInpatientBedUtilization: Double = -1 // Percent of staffed inpatient beds occupied by COVID-19 patients (7 day average)
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

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

extension Dictionary where Key == String {
    func extract(_ key: String) -> String? {
        guard let value = self[key] as? String else {
            debugPrint("Value missing from dictionary: \(key)")
            return nil
        }
        return value
    }
}

extension Date {
    static func fromSocrataFloatingTimestamp(_ isoDate: String) -> Date? {
        // Interpret the iso date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        guard let date = dateFormatter.date(from: isoDate) else { return nil }

        // Now for the current timezone
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return calendar.date(from: components)
    }
}

extension TransmissionData {
    init(json: [String: Any]) {
        // Extract simple string data
        let state = json.extract("state_name")
        let level = json.extract("community_transmission_level")
        let county = json.extract("county_name")
        let countyFips = json.extract("fips_code")
        
        var percentPositiveTestsLast7Days: Double?
        if let x = json.extract("percent_test_results_reported") {
            percentPositiveTestsLast7Days = Double(x)
        }
        
        // Date is a little special. Socrata dates are ISO8601 Times with no timezone offset
        // https://dev.socrata.com/docs/datatypes/floating_timestamp.html
        // https://stackoverflow.com/questions/36861732/convert-string-to-date-in-swift
        var date: Date?
        if let x = json.extract("report_date") {
            date = Date.fromSocrataFloatingTimestamp(x)
        }
        
        // This value might be 'supressed' if it is positive but less than 10
        var newCasesPer100kLast7Days: Double?
        if let x = json.extract("cases_per_100k_7_day_count") {
            if x == "suppressed" {
                newCasesPer100kLast7Days = nil // Means 0<x<10
            }
            else {
                newCasesPer100kLast7Days = Double(x)
            }
        }
        
        // Initialize properties
        if let level = level {
            self.level = level
        }
        if let state = state {
            self.state = state
        }
        if let county = county {
            self.county = county
        }
        if let countyFips = countyFips {
            self.countyFips = countyFips
        }
        if let date = date {
            self.date = date
        }
        if let percentPositiveTestsLast7Days = percentPositiveTestsLast7Days {
            self.percentPositiveTestsLast7Days = percentPositiveTestsLast7Days
        }
        self.newCasesPer100kLast7Days = newCasesPer100kLast7Days
        self.historical = [] // Not handled by the json reader. The json reader just reads a single instance.
    }
        
    static func requestList(state: String, county: String, completion: @escaping ([TransmissionData]) -> Void) {
        var urlComponents = URLComponents(string: "https://data.cdc.gov/resource/8396-v7yb.json")!
        urlComponents.queryItems = [URLQueryItem(name: "state_name", value: state), URLQueryItem(name: "county_name", value: county)]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setValue("X-App-Token", forHTTPHeaderField: "f3fjentqIxjN6C9UkGM3TfzjD")

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var transmissions: [TransmissionData] = []
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<[String: Any]> {
                for item in json {
                    let transmission = TransmissionData(json: item)
                    transmissions.append(transmission)
                }
            }
            
            completion(transmissions)
        }

        task.resume()
    }
    
    static func request(state: String, county: String, completion: @escaping (TransmissionData) -> Void) {
        requestList(state: state, county: county) { (transmissions) in
            if transmissions.isEmpty {
                completion(TransmissionData())
                return
            }
            var transmission = transmissions.first!
            transmission.historical = Array(transmissions[1...])
            completion(transmission)
        }
    }
}

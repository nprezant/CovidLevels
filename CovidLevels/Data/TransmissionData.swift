//
//  TransmissionData.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation
import SwiftUI

struct TransmissionData : SocrataDataSource {
    // Data source: https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-County-Level-of-Community-T/8396-v7yb
    // Updated daily
    static var socrataEndpointId: String = "8396-v7yb"
    var id = UUID() // Each instance will be uniquely identifiable
    var level: String = "-" // Options: low, moderate, substantial, high, blank
    var state: String = "-"
    var county: String = "-"
    var countyFips: String = "-" // Zero padded
    var date: Date = Date.today
    var percentPositiveTestsLast7Days: Double = -1
    var newCasesPer100kLast7Days: Double? = -1 // May be "suppressed" if number is low but non-zero
    var historical: [TransmissionData] = []
    
    var levelColor: Color {
        return Color(level: level)
    }
    
    mutating func update(from t: TransmissionData) {
        level = t.level
        state = t.state
        county = t.county
        countyFips = t.countyFips
        date = t.date
        percentPositiveTestsLast7Days = t.percentPositiveTestsLast7Days
        newCasesPer100kLast7Days = t.newCasesPer100kLast7Days
        historical = t.historical
    }
    
    init() {}
    
    init(json: [String: Any]) {
        // Extract simple string data
        let state = json.extract("state_name")
        let level = json.extract("community_transmission_level")
        let county = json.extract("county_name")
        let countyFips = json.extract("fips_code")
        
        let percentPositiveTestsLast7Days = json.extract("percent_test_results_reported", conversionFunc: Double.init)
        let date = json.extract("report_date", conversionFunc: Date.fromSocrataFloatingTimestamp)
        
        // This value might be 'supressed' if it is positive but less than 10
        var newCasesPer100kLast7Days: Double?
        if let x = json.extract("cases_per_100k_7_day_count") {
            if x == "suppressed" {
                newCasesPer100kLast7Days = nil // Means 0 < x < 10
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

    private static func requestList(state: String, county: String) -> [TransmissionData] {
        var urlComponents = URLComponents(string: TransmissionData.socrataEndpoint)!
        urlComponents.queryItems = [
            URLQueryItem(name: "state_name", value: state),
            URLQueryItem(name: "county_name", value: county),
            URLQueryItem(name: "$order", value: "report_date DESC"),
            URLQueryItem(name: "$limit", value: "14"), // two weeks
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setSocrataHeader()
        
        let group = DispatchGroup()
        group.enter()
        var transmissions: [TransmissionData] = []

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<[String: Any]> {
                for item in json {
                    let transmission = TransmissionData(json: item)
                    transmissions.append(transmission)
                }
            }
            
            group.leave()
        }

        task.resume()
        group.wait()
        return transmissions
    }
    
    static func requestUpdate(state: String, county: String) -> TransmissionData? {
        let transmissions = TransmissionData.requestList(state: state, county: county)
        if transmissions.isEmpty {
            return nil
        }
        var transmission = transmissions.first!
        transmission.historical = Array(transmissions)
        return transmission
    }
    
    static func request(state: String, county: String, completion: @escaping (TransmissionData) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
        
            // Name of stored data
            let cacheName = "\(state)-\(county)-Transmission.cache".replacingOccurrences(of: " ", with: "-")
            
            // If there is no data already stored, we'll need to read in new data
            guard let cache : DataCache<TransmissionData> = DataCacheService.getCache(cacheName) else {
                if let data = requestUpdate(state: state, county: county) {
                    DataCacheService.save(data, name: cacheName) // only save if data is found
                    completion(data)
                }
                return
            }
            
            // Okay, so we have some stored data. Display it.
            // If there is no internet connection old data is better than no data.
            completion(cache.data)
            
            // Check for an update.
            // If cached data is up to date we can use it.
            // Otherwise we'll need to fetch the update.
            EndpointStatusChecker.shared.check(id: TransmissionData.socrataEndpointId, against: cache.modificationDate) { status in
                switch status {
                case .UpToDate:
                    // Pass. Stored data is already displayed.
                    break
                case .OutOfDate:
                    if let data = requestUpdate(state: state, county: county) {
                        DataCacheService.save(data, name: cacheName)
                        completion(data)
                    }
                    break
                }
            }
        }
    }
}

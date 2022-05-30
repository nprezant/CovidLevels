//
//  CommunityData.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import Foundation
import SwiftUI

struct CommunityData : SocrataDataSource {
    // Data source: https://data.cdc.gov/Public-Health-Surveillance/United-States-COVID-19-Community-Levels-by-County/3nnm-4jni
    // Updated weekly
    static var socrataEndpointId: String = "3nnm-4jni"
    var id = UUID() // Each instance will be uniquely identifiable
    var level: String = "-" // Options: Low, Medium, High
    var dateUpdated: Date = Date.today
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
    
    var levelColor: Color {
        return Color(level: level)
    }
    
    init() {}
    
    init(json: [String: Any]) {
        // Extract simple string data
        let state = json.extract("state")
        let level = json.extract("covid_19_community_level")
        let county = json.extract("county")
        let countyFips = json.extract("county_fips")
        let healthServiceArea = json.extract("health_service_area")
        
        let countyPopulation = json.extract("county_population", conversionFunc: Int.init)
        let healthServiceAreaPopulation = json.extract("health_service_area_population", conversionFunc: Int.init)
        let healthServiceAreaNumber = json.extract("health_service_area_number", conversionFunc: Int.init)
        
        let covidInpatientBedUtilization = json.extract("covid_inpatient_bed_utilization", conversionFunc: Double.init)
        let covidHospitalAdmissionsPer100k = json.extract("covid_hospital_admissions_per_100k", conversionFunc: Double.init)
        let covidCasesPer100k = json.extract("covid_cases_per_100k", conversionFunc: Double.init)
        
        let date = json.extract("date_updated", conversionFunc: Date.fromSocrataFloatingTimestamp)
        
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
            self.dateUpdated = date
        }
        if let healthServiceArea = healthServiceArea {
            self.healthServiceArea = healthServiceArea
        }
        if let countyPopulation = countyPopulation {
            self.countyPopulation = countyPopulation
        }
        if let healthServiceAreaPopulation = healthServiceAreaPopulation {
            self.healthServiceAreaPopulation = healthServiceAreaPopulation
        }
        if let healthServiceAreaNumber = healthServiceAreaNumber {
            self.healthServiceAreaNumber = healthServiceAreaNumber
        }
        if let covidInpatientBedUtilization = covidInpatientBedUtilization {
            self.covidInpatientBedUtilization = covidInpatientBedUtilization
        }
        if let covidHospitalAdmissionsPer100k = covidHospitalAdmissionsPer100k {
            self.covidHospitalAdmissionsPer100k = covidHospitalAdmissionsPer100k
        }
        if let covidCasesPer100k = covidCasesPer100k {
            self.covidCasesPer100k = covidCasesPer100k
        }
        self.historical = [] // Not handled by the json reader. The json reader just reads a single instance.
    }
        
    private static func requestList(state: String, county: String, completion: @escaping ([CommunityData]) -> Void) {
        var urlComponents = URLComponents(string: CommunityData.socrataEndpoint)!
        urlComponents.queryItems = [
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "county", value: county),
            URLQueryItem(name: "$order", value: "date_updated DESC"),
            URLQueryItem(name: "$limit", value: "10"), // ten weeks
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setSocrataHeader()

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var communities: [CommunityData] = []
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<[String: Any]> {
                for item in json {
                    let community = CommunityData(json: item)
                    communities.append(community)
                }
            }
            
            completion(communities)
        }

        task.resume()
    }
    
    static func requestUpdate(state: String, county: String, completion: @escaping (CommunityData) -> Void) {
        CommunityData.requestList(state: state, county: county) { (communities) in
            if communities.isEmpty {
                completion(CommunityData())
                return
            }
            var community = communities.first!
            community.historical = communities.count >= 2 ? Array(communities[1...]) : []
            completion(community)
        }
    }
    
    static func request(state: String, county: String, completion: @escaping (CommunityData) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
        
            // Name of stored data
            let cacheName = "\(state)-\(county)-Community.cache".replacingOccurrences(of: " ", with: "-")
            
            // Read in stored data. If there is no data stored, we'll need to update
            guard let cache : DataCache<CommunityData> = DataCacheService.getCache(cacheName) else {
                requestUpdate(state: state, county: county) { data in
                    DataCacheService.save(data, name: cacheName)
                    completion(data)
                }
                return
            }
            
            // Okay, so we have some stored data. If it is up to date we can use it.
            // If it is out of date we'll need to update it.
            EndpointStatusChecker.shared.check(id: CommunityData.socrataEndpointId, against: cache.modificationDate) { status in
                switch status {
                case .UpToDate:
                    completion(cache.data)
                case .OutOfDate:
                    requestUpdate(state: state, county: county) { data in
                        DataCacheService.save(data, name: cacheName)
                        completion(data)
                    }
                }
            }
        }
    }
}

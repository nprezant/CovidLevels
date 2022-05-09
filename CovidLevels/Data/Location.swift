//
//  Location.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import Foundation

class Locations : ObservableObject {
    @Published var locations: [Location] = []
    
    func request() {
        for loc in locations {
            loc.request()
        }
    }
}

class Location : Identifiable, ObservableObject {
    var id: String {
        return state + county
    }
    var state: String
    var county: String
    @Published var comm: CommunityData = CommunityData()
    @Published var trans: TransmissionData = TransmissionData()
    
    init(state: String, county: String) {
        self.state = state
        self.county = county
    }
    
    func request() {
        TransmissionData.request(state: state, county: county) { [weak self] transmission in
            guard let self = self else { return }
            debugPrint("Got transmission data. \(transmission.county.withoutCounty): \(transmission.level)")
            DispatchQueue.main.async {
                self.trans = transmission
            }
        }
        CommunityData.request(state: state, county: county) { [weak self] community in
            guard let self = self else { return }
            debugPrint("Got community data. \(community.healthServiceArea)")
            DispatchQueue.main.async {
                self.comm = community
            }
        }
    }
}

extension Locations {
    static var example: Locations {
        let locs = Locations()
        locs.locations = [
            Location(state: "Colorado", county: "Larimer County"),
            Location(state: "North Carolina", county: "Buncombe County")
        ]
        return locs
    }
    static var exampleWithData: Locations {
        let locs = Locations()
        locs.locations = [
            Location(state: "Colorado", county: "Larimer County"),
            Location(state: "North Carolina", county: "Buncombe County")
        ]
        locs.locations[0].comm = CommunityData.exampleData.first!
        locs.locations[0].trans = TransmissionData.exampleData.first!
        locs.locations[1].comm = CommunityData.exampleData.first!
        locs.locations[1].trans = TransmissionData.exampleData.first!
        return locs
    }
}

extension Location {
    static var example: Location {
        return Locations.example.locations.first!
    }
    static var example2: Location {
        return Locations.example.locations.last!
    }
    static var exampleWithData: Location {
        let loc = Locations.example.locations.first!
        loc.comm = CommunityData.exampleData.first!
        loc.trans = TransmissionData.exampleData.first!
        return loc
    }
}

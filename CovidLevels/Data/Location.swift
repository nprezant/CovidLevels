//
//  Location.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import Foundation
import os

fileprivate var locationsFileUrl: URL {
    return FileLocations.documentsFolder.appendingPathComponent("locations.json")
}

class Locations : ObservableObject {
    @Published var locations: [Location] = []
    
    func add(_ loc: Location) {
        locations.append(loc)
        save()
    }
    
    func remove(at index: Array.Index) {
        locations.remove(atOffsets: IndexSet([index]))
        save()
    }
    
    func request() {
        for loc in locations {
            loc.request()
        }
    }
    
    static func fromFile() -> Locations {
        let locations: Array<Location> = .init(file: locationsFileUrl)
        let res = Locations()
        res.locations = locations
        return res
    }
    
    private func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            Logger().info("Saving locations")
            self.locations.save(file: locationsFileUrl)
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
        CommunityData.request(state: state, county: county) { [weak self] community in
            guard let self = self else { return }
            debugPrint("Got community data. \(self.county), \(self.state): \(community.level)")
            DispatchQueue.main.async {
                self.comm = community
            }
        }
        TransmissionData.request(state: state, county: county) { [weak self] transmission in
            guard let self = self else { return }
            debugPrint("Got transmission data. \(self.county), \(self.state): \(transmission.level)")
            DispatchQueue.main.async {
                self.trans = transmission
            }
        }
    }
}

struct LocationData : Codable {
    var state: String
    var county: String
}

extension Array where Element == Location {
    init(file: URL) {
        Logger().info("Loading locations from file: \(file)")
        guard let data = try? Data(contentsOf: file) else {
            Logger().info("Locations file does not exist.")
            self.init(Locations.example.locations)
            return
        }
        guard let locationDataList = try? JSONDecoder().decode(Array<LocationData>.self, from: data) else {
            Logger().warning("Error decoding locations file. Removing file. Using default locations.")
            try? FileManager.default.removeItem(at: file)
            self.init(Locations.example.locations)
            return
        }
        self.init(locationDataList.map{ Location(state: $0.state, county: $0.county) })
    }
    
    func save(file: URL) {
        Logger().info("Saving locations file: \(file)")
        let locationDataList = self.map{ LocationData(state: $0.state, county: $0.county) }
        guard let data = try? JSONEncoder().encode(locationDataList.self) else {
            Logger().warning("Error encoding locations data.")
            return
        }
        do {
            try data.write(to: file)
        } catch {
            Logger().warning("Error writing to locations data file.")
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

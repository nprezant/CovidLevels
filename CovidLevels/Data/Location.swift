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

struct MajorRegion : Identifiable {
    let id = UUID()
    var name: String
    var locations: [Location]
}

class Locations : ObservableObject {
    @Published var allLocations: [Location] = []
    @Published var states: [MajorRegion] = []
    
    private var timer: Timer? = nil
    private var lastUpdate: LastUpdatedService = .shared
    static private let staleTolerance: TimeInterval = .minutes(30)
    
    func add(_ loc: Location) {
        allLocations = (allLocations + [loc]).sorted(by: {$0.county < $1.county})
        buildStates()
        save()
    }
    
    func remove(at index: Array.Index) {
        allLocations.remove(atOffsets: IndexSet([index]))
        buildStates()
        save()
    }
    
    func remove(location: Location) {
        allLocations.removeAll(where: {$0.id == location.id})
        buildStates()
        save()
    }
    
    func requestIfStale() {
        var isStale: Bool = true
        if let lastChecked = lastUpdate.lastUpdatedDate {
            let timeSinceLastChecked = -1 * lastChecked.timeIntervalSinceNow
            if timeSinceLastChecked > Locations.staleTolerance {
                isStale = false
            }
        }
        if isStale {
            request()
        }
    }
    
    func request() {
        lastUpdate.registerChange()
        if timer == nil {
            timer = .scheduledTimer(withTimeInterval: .minutes(15), repeats: true, block: {_ in self.requestIfStale()})
        }
        for loc in allLocations {
            loc.request()
        }
    }
    
    static func fromFile() -> Locations {
        let locations: Array<Location> = .init(file: locationsFileUrl)
        let res = Locations()
        res.allLocations = locations
        res.buildStates()
        return res
    }
    
    private func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            Logger().info("Saving locations")
            self.allLocations.save(file: locationsFileUrl)
        }
    }
    
    private func buildStates() {
        let d = Dictionary(grouping: allLocations, by: {x in return x.state}).sorted(by: {$0.key < $1.key})
        states = d.map({MajorRegion(name: $0.key, locations: $0.value)})
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
            DispatchQueue.main.async {
                self.comm = community
            }
        }
        TransmissionData.request(state: state, county: county) { [weak self] transmission in
            guard let self = self else { return }
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
            self.init(Locations.appDefault.allLocations)
            return
        }
        guard let locationDataList = try? JSONDecoder().decode(Array<LocationData>.self, from: data) else {
            Logger().warning("Error decoding locations file. Removing file. Using default locations.")
            try? FileManager.default.removeItem(at: file)
            self.init(Locations.appDefault.allLocations)
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
        locs.allLocations = [
            Location(state: "Colorado", county: "Larimer County"),
            Location(state: "North Carolina", county: "Buncombe County")
        ]
        locs.buildStates()
        return locs
    }
    static var appDefault: Locations {
        let locs = Locations()
        locs.allLocations = [
            Location(state: "Colorado", county: "Arapahoe County"),
            Location(state: "Colorado", county: "El Paso County"),
            Location(state: "Colorado", county: "Routt County")
        ]
        locs.buildStates()
        return locs
    }
    static var exampleWithData: Locations {
        let locs = Locations()
        locs.allLocations = [
            Location(state: "Colorado", county: "Larimer County"),
            Location(state: "North Carolina", county: "Buncombe County")
        ]
        locs.allLocations[0].comm = CommunityData.exampleData.first!
        locs.allLocations[0].trans = TransmissionData.exampleData.first!
        locs.allLocations[1].comm = CommunityData.exampleData.first!
        locs.allLocations[1].trans = TransmissionData.exampleData.first!
        locs.buildStates()
        return locs
    }
}

extension Location {
    static var example: Location {
        return Locations.example.allLocations.first!
    }
    static var example2: Location {
        return Locations.example.allLocations.last!
    }
    static var exampleWithData: Location {
        let loc = Locations.example.allLocations.first!
        loc.comm = CommunityData.exampleData.first!
        loc.trans = TransmissionData.exampleData.first!
        return loc
    }
}

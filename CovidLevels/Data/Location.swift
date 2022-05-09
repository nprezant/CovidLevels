//
//  Location.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import Foundation

struct Location : Identifiable {
    var id: String {
        return state + county
    }
    var state: String
    var county: String
    var comm: CommunityData = CommunityData()
    var trans: TransmissionData = TransmissionData()
}

extension Location {
    static var example: Location {
        return examples.first!
    }
    static var examples: [Location] {
        return [
            Location(state: "Colorado", county: "Larimer County"),
            Location(state: "North Carolina", county: "Buncombe County")
        ]
    }
}

//
//  CountyCrosswalk.swift
//  CovidLevels
//
//  Created by Noah on 5/17/22.
//

import Foundation

class Crosswalk : Hashable, Equatable {
    let stateCode: Int
    let zctaCode: String
    let countyCode: Int
    let stateAbbreviation: String
    let countyName: String
    let placeName: String
    let zctaName: String
    let county: String
    
    var foundWith: String? = nil
    
    static func == (lhs: Crosswalk, rhs: Crosswalk) -> Bool {
        return lhs.county == rhs.county
            && lhs.stateCode == rhs.stateCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(county)
        hasher.combine(stateCode)
    }
    
    init?(fromLine line: String) {
        // Assumes that all fields are quoted
        if line.isEmpty {
            return nil
        }
        
        var line = line
        
        // Removes first and last quote characters
        line.removeFirst()
        line.removeLast()
        
        // Split on "," since all fields are quoted
        let tokens = line.components(separatedBy: "\",\"")
        guard tokens.count == 8 else {
            print("Expected 8 tokens in crosswalk csv row. Got \(tokens.count). \(line)")
            return nil
        }
        
        // Decode values
        if let stateCode = Int(tokens[0]),
           let countyCode = Int(tokens[2]) {
            
            let zctaCode = tokens[1]
            let stateAbbreviation = tokens[3]
            let countyName = tokens[4]
            let placeName = tokens[5]
            let zctaName = tokens[6]
            let county = tokens[7]
            
            self.stateCode = stateCode
            self.zctaCode = zctaCode
            self.countyCode = countyCode
            self.stateAbbreviation = stateAbbreviation
            self.countyName = countyName
            self.placeName = placeName
            self.zctaName = zctaName
            self.county = county
        } else {
            print("Error decoding crosswalk line: \(line)")
            return nil
        }
    }
}

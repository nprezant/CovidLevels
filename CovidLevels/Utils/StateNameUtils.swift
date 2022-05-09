//
//  StateNameUtils.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import Foundation

fileprivate let stateNamesShortToLong: [String : String] = [
    "AK" : "Alaska",
    "AL" : "Alabama",
    "AR" : "Arkansas",
    "AS" : "American Samoa",
    "AZ" : "Arizona",
    "CA" : "California",
    "CO" : "Colorado",
    "CT" : "Connecticut",
    "DC" : "District of Columbia",
    "DE" : "Delaware",
    "FL" : "Florida",
    "GA" : "Georgia",
    "GU" : "Guam",
    "HI" : "Hawaii",
    "IA" : "Iowa",
    "ID" : "Idaho",
    "IL" : "Illinois",
    "IN" : "Indiana",
    "KS" : "Kansas",
    "KY" : "Kentucky",
    "LA" : "Louisiana",
    "MA" : "Massachusetts",
    "MD" : "Maryland",
    "ME" : "Maine",
    "MI" : "Michigan",
    "MN" : "Minnesota",
    "MO" : "Missouri",
    "MS" : "Mississippi",
    "MT" : "Montana",
    "NC" : "North Carolina",
    "ND" : "North Dakota",
    "NE" : "Nebraska",
    "NH" : "New Hampshire",
    "NJ" : "New Jersey",
    "NM" : "New Mexico",
    "NV" : "Nevada",
    "NY" : "New York",
    "OH" : "Ohio",
    "OK" : "Oklahoma",
    "OR" : "Oregon",
    "PA" : "Pennsylvania",
    "PR" : "Puerto Rico",
    "RI" : "Rhode Island",
    "SC" : "South Carolina",
    "SD" : "South Dakota",
    "TN" : "Tennessee",
    "TX" : "Texas",
    "UT" : "Utah",
    "VA" : "Virginia",
    "VI" : "Virgin Islands",
    "VT" : "Vermont",
    "WA" : "Washington",
    "WI" : "Wisconsin",
    "WV" : "West Virginia",
    "WY" : "Wyoming"]

class StateNames {
    static let shortToLong = stateNamesShortToLong
    
    private static var longToShort_: [String:String]? = nil
    static var longToShort: [String:String] {
        if let x = longToShort_ {
            return x
        }
        longToShort_ = [String:String]()
        for pair in shortToLong {
            longToShort_![pair.value.uppercased()] = pair.key
        }
        return longToShort_!
    }
}

extension String {
    var asLongStateName: String {
        return StateNames.shortToLong[self.uppercased(), default: self]
    }
    
    var asShortStateName: String {
        return StateNames.longToShort[self.uppercased(), default: self]
    }
    
    var withoutCounty: String {
        return self.replacingOccurrences(of: " County", with: "")
    }
}

//
//  SearchItem.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation

struct SearchItem : Identifiable, Hashable {
    let location: Location
    var crosswalk: String? = nil
    var id : String { return label }
    var label: String {
        var cw: String = ""
        if let crosswalk = crosswalk {
            cw = " (\(crosswalk))"
        }
        return "\(location.county), \(location.state.asShortStateName)" + cw
    }
    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension SearchItem {
    private static func queryMatches(stateSearches: [String], countySearches: [String], limit: Int, crosswalk: String?, completion: @escaping (([SearchItem]) -> Void)) {
        
        // Set up api call to find distinct states and counties
        var urlComponents = URLComponents(string: CommunityData.socrataEndpoint)!
        let stateQuery = stateSearches.map{"state LIKE '%\($0)%'"}.joined(separator: " OR ")
        let countyQuery = countySearches.map{"county LIKE '%\($0)%'"}.joined(separator: " OR ")
        urlComponents.queryItems = [
            URLQueryItem(name: "$query", value: "SELECT DISTINCT state,county WHERE (\(stateQuery)) OR (\(countyQuery)) LIMIT \(limit)"),
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setSocrataHeader()

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            var searchItems: [SearchItem] = []
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<[String: Any]> {
                for item in json {
                    if let state = item.extract("state"), let county = item.extract("county") {
                        searchItems.append(SearchItem(location: Location(state: state, county: county), crosswalk: crosswalk))
                    }
                }
            }
            
            completion(searchItems)
        }

        task.resume()
    }
    
    static let searchListLength: Int = 12
    
    static func provider(searchText: String, completion: @escaping (([SearchItem]) -> Void)) {        
        // When no text is provided, provide no suggestions
        if searchText.isEmpty || searchText.count < 2 {
            completion([])
            return
        }
        
        print("Searching \(searchText)")
        
        // If the search text appears to be a city or zip code, figure out which counties / states that would correspond to
        let isPossibleZipCode = searchText.matches(regex: "\\d{2,4}")
        let isPossibleCity = searchText.matches(regex: "^[^0-9]+$")
        
        // If this looks like a zip code, don't try to treat it as a state or county
        if isPossibleZipCode {
            CrosswalkService.shared.find(text: searchText, types: [.zip], limit: searchListLength) { zipCodeMatches in
                completion(zipCodeMatches.asSearchItems)
            }
            return
        }
        
        // Try to match on the city name
        if isPossibleCity {
            CrosswalkService.shared.find(text: searchText, types: [.city, .county], limit: searchListLength) { matches in
                completion(matches.asSearchItems)
            }
            return
        }
        
        // This shouldn't happen, but just search for county as a backup
        CrosswalkService.shared.find(text: searchText, types: [.county], limit: searchListLength) { countyMatches in
            completion(countyMatches.asSearchItems)
        }
    }
}
    
extension Array where Element == Crosswalk {
    var asSearchItems: [SearchItem] {
        return self.map{
            SearchItem(
                location: Location(state: $0.stateAbbreviation.asLongStateName, county: $0.county.withCounty),
                crosswalk: $0.foundWith)
        }
    }
}

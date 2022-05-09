//
//  SearchItem.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation

struct SearchItem : Identifiable {
    let location: Location
    var id : String { return label }
    var label: String { return "\(location.county), \(location.state)" }
}

extension SearchItem {
    static func provider(searchText: String, completion: @escaping (([SearchItem]) -> Void)) {
        // When no text is provided, provide no suggestions
        if searchText.isEmpty || searchText.count < 2 { return }
        
        // Set up api call to find distinct states and counties
        var urlComponents = URLComponents(string: CommunityData.apiEndpoint)!
        urlComponents.queryItems = [
            URLQueryItem(name: "$query", value: "SELECT DISTINCT state,county WHERE state LIKE '%\(searchText)%' OR county LIKE '%\(searchText)%' LIMIT 12"),
//            URLQueryItem(name: "$order", value: "report_date DESC"),
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
                        searchItems.append(SearchItem(location: Location(state: state, county: county)))
                    }
                }
            }
            
            completion(searchItems)
        }

        task.resume()
    }
}

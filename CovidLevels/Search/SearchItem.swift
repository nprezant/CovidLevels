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
    static func provider(searchText: String) -> [SearchItem] {
        // When no text is provided, provide no suggestions
        if searchText.isEmpty {
            return []
        }
        
        // TODO make API call to find items
        return [SearchItem(location: .example), SearchItem(location: .example2)]
    }
}

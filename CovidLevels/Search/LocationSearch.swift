//
//  LocationSearch.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import SwiftUI

struct LocationSearch: View {
    @State var searchText: String = ""
    let provider: ((String) -> [SearchItem]) = SearchItem.provider
    var body: some View {
        VStack {
            Text("Enter U.S. state or county location")
                .font(.caption)
                .padding([.top])
            SearchBar(text: $searchText)
            ScrollView {
                ForEach(provider(searchText)) { item in
                    SearchItemView(item: item, searchText: searchText)
                }
            }
        }
    }
}

struct LocationSearch_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearch(searchText: "Larimer")
    }
}

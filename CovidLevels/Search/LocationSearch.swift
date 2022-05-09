//
//  LocationSearch.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import SwiftUI

struct LocationSearch: View {
    @State var searchText: String = ""
    @State var searchItems: [SearchItem] = []
    
    func updateSearchItems(_ searchText: String) {
        SearchItem.provider(searchText: searchText) { items in
            searchItems = items // todo may need to put on main thread
        }
    }
    
    var body: some View {
        VStack {
            Text("Enter U.S. state or county location")
                .font(.caption)
                .padding([.top])
            SearchBar(text: $searchText)
                .onChange(of: searchText) { s in updateSearchItems(s) }
            ScrollView {
                ForEach(searchItems) { item in
                    SearchItemView(item: item, searchText: searchText)
                        .padding([.leading])
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

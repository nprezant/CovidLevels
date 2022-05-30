//
//  LocationSearch.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import SwiftUI

struct LocationSearch: View {
    let locationAdded: ((Location) -> Void)
    
    @State private var searchText: String = ""
    @State private var searchItems: [SearchItem] = []

    @State private var showingPreview: Bool = false
    @State private var previewLocation: Location? = nil
    
    func updateSearchItems(_ searchText: String) {
        SearchItem.provider(searchText: searchText) { items in
            print("Applying \(items.count) items to suggestions")
            searchItems = items.distinct() // UI cannot loop over a list with duplicates
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
                        .padding([.leading, .top])
                        .onTapGesture {
                            previewLocation = item.location
                            previewLocation?.request()
                            showingPreview = true
                        }
                }
            }
            // Silly.
            // https://developer.apple.com/forums/thread/652080
            let _ = "\(previewLocation?.state ?? "none")"
        }
        .sheet(isPresented: $showingPreview, onDismiss: { print("Location preview dismissed") }) {
            if let previewLocation = previewLocation {
                ZStack {
                    PageView(loc: previewLocation)
                        .padding([.top])
                    VStack {
                        HStack {
                            Button("Cancel") { showingPreview = false }
                                .padding()
                            Spacer()
                            Button("Add") { locationAdded(previewLocation); showingPreview = false }
                                .padding()
                        }
                        Spacer()
                    }
                }
            } else {
                Text("No preview location selected")
            }
        }
    }
}

struct LocationSearch_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearch() { _ in }
    }
}

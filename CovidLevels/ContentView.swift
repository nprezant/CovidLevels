//
//  ContentView.swift
//  CovidLevels
//
//  Created by Noah on 5/5/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locations: Locations = .fromFile()
    
    @State var showingDetail: Bool = false
    @State var selectedDetail: Location? = nil
    
    @State var showingSearch: Bool = false
    
    var body: some View {
        if showingDetail, let selectedDetail = selectedDetail {
            PageView(loc: selectedDetail)
                .floatingButton(imageSystemName: "list.bullet") {
                    showingDetail = false
                }
        } else {
            List {
                ForEach(self.locations.states) { state in
                    Section(header: Text(state.name)) {
                        ForEach(state.locations) { loc in
                            LocationCardView(location: loc)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedDetail = loc
                                    withAnimation {
                                        showingDetail = true
                                    }
                                }
                        }
                        .onDelete { idx in
                            withAnimation {
                                let l = state.locations.enumerated().filter({idx.contains($0.offset)})
                                for (_,location) in l {
                                    locations.remove(location: location)
                                }
                            }
                        }
                    }
                }
                // An empty view to give a bit of extra space at the bottom
                Section(header: Text("")) {
                    EmptyView()
                }
            }
            .listStyle(.insetGrouped)
            .floatingButton(imageSystemName: "magnifyingglass") {
                showingSearch = true
            }
            .onAppear {
                print("Requesting all locations")
                locations.request()
            }
            .sheet(isPresented: $showingSearch, onDismiss: { print("Search dismissed") }) {
                LocationSearch() { loc in
                    locations.add(loc)
                    showingSearch = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

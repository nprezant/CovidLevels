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
            VStack {
                PageView(loc: selectedDetail)
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showingDetail = false
                        }
                    }) {
                        Image(systemName: "list.bullet")
                            .padding()
                    }
                }
            }
        } else {
            ZStack {
                List {
                    ForEach(self.locations.states) { state in
                        Section(header: Text(state.name)) {
                            ForEach(state.locations) { loc in
                                LocationCardView(location: loc)
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
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .padding()
                                .background(Color.white.opacity(1))
                                .clipShape(Capsule())
                        }
                        .shadow(radius: 10)
                    }
                }
                .padding()
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

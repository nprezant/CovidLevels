//
//  ContentView.swift
//  CovidLevels
//
//  Created by Noah on 5/5/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locations: Locations = Locations.example
    
    @State var showingDetail: Bool = false
    @State var detailIndex: Int = 0
    
    @State var showingSearch: Bool = false
    
    var body: some View {
        if showingDetail {
            VStack {
                PageView(loc: locations.locations[detailIndex])
                HStack {
                    Spacer()
                    Button(action: {
                        showingDetail = false
                    }) {
                        Image(systemName: "list.bullet")
                            .padding()
                    }
                }
            }
        } else {
            ScrollView {
                VStack {
                    ForEach(self.locations.locations.indices) { index in
                        LocationCardView(location: self.locations.locations[index])
                            .onTapGesture {
                                detailIndex = index
                                showingDetail = true
                            }
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingSearch = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding()
                        }
                    }
                }
            }
            .onAppear {
                debugPrint("Requesting all locations")
                locations.request()
            }
            .sheet(isPresented: $showingSearch, onDismiss: { debugPrint("dismissed") }) {
                LocationSearch()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

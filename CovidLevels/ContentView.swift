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
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(self.locations.locations.indices) { index in
                    LocationCardView(location: self.locations.locations[index])
                }
            }
        }.onAppear {
            for loc in locations.locations {
                loc.request()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

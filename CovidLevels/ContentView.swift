//
//  ContentView.swift
//  CovidLevels
//
//  Created by Noah on 5/5/22.
//

import SwiftUI

struct ContentView: View {
    @State var locations: [Location] = Location.examples
    
    @State var showingDetail: Bool = false
    @State var detailIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(self.locations.indices) { index in
                    LocationCardView(location: self.$locations[index])
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

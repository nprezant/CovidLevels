//
//  LocationCardView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct LocationCardView: View {
    @ObservedObject var location: Location
    var body: some View {
        HStack {
            Text("\(location.county.withoutCounty), \(location.state.asShortStateName)")
                .font(.body)
            Spacer()
            Text(location.comm.level)
                .font(.body.smallCaps())
                .padding()
        }
        .foregroundColor(.primary)
        .padding(.leading).padding(.trailing)
        .background(location.comm.levelColor)
    }
}

struct LocationCardView_Previews: PreviewProvider {
    static var previews: some View {
        LocationCardView(location: Location.example)
    }
}

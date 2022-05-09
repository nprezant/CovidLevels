//
//  LocationCardView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct LocationCardView: View {
    @Binding var location: Location
    var body: some View {
        HStack {
            Text("\(location.county.withoutCounty()), \(location.state.toShortStateName())")
                .font(.body)
            Spacer()
            Text(location.trans.level)
                .font(.body.smallCaps())
                .padding()
        }
        .foregroundColor(.primary)
        .padding(.leading).padding(.trailing)
        .background(location.trans.levelColor())
    }
}

struct LocationCardView_Previews: PreviewProvider {
    static var previews: some View {
        LocationCardView(location: .constant(Location.example))
    }
}

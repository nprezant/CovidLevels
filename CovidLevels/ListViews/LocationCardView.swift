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
            let rectSize = "M".height(withConstrainedWidth: 0, font: .preferredFont(forTextStyle: .body))
            Rectangle()
                .fill(location.comm.levelColor)
                .frame(width: rectSize, height: rectSize)
            Text("\(location.county.withoutCounty), \(location.state.asShortStateName)")
                .font(.title2)
            Spacer()
            Text(location.comm.level)
                .font(.largeTitle.smallCaps())
        }
        .foregroundColor(.primary)
    }
}

struct LocationCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LocationCardView(location: Location.exampleWithData)
            LocationCardView(location: Location.example)
            LocationCardView(location: Location.example2)
        }
    }
}

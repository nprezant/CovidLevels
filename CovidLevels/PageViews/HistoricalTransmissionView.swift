//
//  HistoricalTransmissionView.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import SwiftUI

struct HistoricalTransmissionView: View {
    let trans: TransmissionData
    var body: some View {
        VStack {
            Text("\(trans.date.formatted("EEEE"))")
                .font(.caption)
            Text(trans.level.uppercased())
                .font(.body.smallCaps())
            Text(trans.date.formatted(dateStyle: .short))
                .font(.body)
        }
        .padding([.leading, .trailing])
        .background(trans.levelColor)
    }
}

struct HistoricalTransmissionView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalTransmissionView(trans: TransmissionData.exampleData.first!)
    }
}

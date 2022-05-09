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
            Spacer()
                .frame(height: 10)
            Text(trans.level.uppercased())
                .font(.body.smallCaps())
            Spacer()
                .frame(height: 10)
            Text(trans.date.formatted(dateStyle: .short))
                .font(.body)
        }
        .padding()
        .background(trans.levelColor())
    }
}

struct HistoricalTransmissionView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalTransmissionView(trans: TransmissionData.exampleData.first!)
    }
}

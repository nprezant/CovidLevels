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
        let shortDate = trans.date.formatted(dateStyle: .short)
        let colorHeight = "l".width(withConstrainedHeight: .greatestFiniteMagnitude, font: .preferredFont(forTextStyle: .body))
        let colorWidth = shortDate.width(withConstrainedHeight: .greatestFiniteMagnitude, font: .preferredFont(forTextStyle: .body))
        VStack(spacing: 0) {
            Text(trans.date.formatted("EEEE"))
                .font(.caption)
            Text(trans.level.uppercased())
                .font(.body.smallCaps())
            Text(shortDate)
                .font(.body)
            Rectangle()
                .fill(trans.levelColor)
                .frame(width: colorWidth, height: colorHeight)
        }
        .padding([.leading, .trailing])
    }
}

struct HistoricalTransmissionView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalTransmissionView(trans: TransmissionData.exampleData.first!)
    }
}

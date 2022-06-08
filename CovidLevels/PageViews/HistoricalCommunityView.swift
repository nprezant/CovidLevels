//
//  HistoricalCardView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct HistoricalCommunityView: View {
    let comms: [CommunityData]
    var body: some View {
        let rectSize = "a".height(withConstrainedWidth: 0, font: .preferredFont(forTextStyle: .body))
        let cols: [GridItem] = [
            .init(.flexible(), spacing: 0, alignment: .leading),
            .init(.flexible(maximum: rectSize * 3), spacing: 50, alignment: .leading),
            .init(.flexible(), spacing: 10, alignment: .trailing),
        ]
        LazyVGrid(columns: cols, spacing: nil) {
            ForEach(comms) { comm in
                Text(comm.dateUpdated.formatted(dateStyle: .short))
                    .font(.body)
                Rectangle()
                    .fill(comm.levelColor)
                    .frame(width: rectSize, height: rectSize)
                Text(comm.level)
                    .font(.body.smallCaps())
            }
        }
    }
}



struct HistoricalCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalCommunityView(comms: CommunityData.exampleData.first!.historical)
    }
}

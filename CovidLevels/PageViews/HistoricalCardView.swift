//
//  HistoricalCardView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct HistoricalCardView: View {
    let comm: CommunityData
    var body: some View {
        HStack {
            Text(comm.dateUpdated.formatted(dateStyle: .medium))
                .font(.body)
            Spacer()
            Text(comm.level)
                .font(.body.smallCaps())
                .padding()
        }
        .foregroundColor(.primary)
        .padding(.leading).padding(.trailing)
        .background(comm.levelColor())
    }
}

struct HistoricalCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalCardView(comm: CommunityData.exampleData.first!)
    }
}

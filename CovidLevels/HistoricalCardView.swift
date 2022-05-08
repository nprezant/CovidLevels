//
//  HistoricalCardView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct HistoricalCardView: View {
    let commData: CommunityData
    var body: some View {
        HStack {
            Text(commData.dateUpdated.formatted())
                .font(.body)
            Spacer()
            Text(commData.level)
                .font(.body.smallCaps())
                .padding()
        }
        .foregroundColor(.primary)
        .padding(.leading).padding(.trailing)
        .background(commData.levelColor())
    }
}

struct HistoricalCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalCardView(commData: CommunityData.exampleData.first!)
    }
}

//
//  PageView.swift
//  CovidCommunityLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct PageView: View {
    let commData: CommunityData
    var body: some View {
        VStack {
            Text("\(commData.county), \(commData.state)")
                .font(.title3)
            Spacer()
                .frame(height: 10)
            HStack {
                Spacer()
                VStack {
                    Text(commData.level.uppercased())
                        .font(.largeTitle)
                    Text("Community Level")
                        .font(.caption2)
                }
                Spacer()
                VStack {
                    Text(commData.transmissionLevel.uppercased())
                        .font(.largeTitle)
                    Text("Transmission Level")
                        .font(.caption2)
                }
                Spacer()
            }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(commData.historical) { historyData in
                        HistoricalCardView(commData: historyData)
                    }
                }
                Divider()
                CommunityDetailsView(commData: commData)
                    .padding([.leading, .trailing, .top, .bottom])
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(commData: CommunityData.exampleData.first!)
    }
}

//
//  PageView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct PageView: View {
    let comm: CommunityData
    let trans: TransmissionData
    var body: some View {
        VStack {
            Text("\(comm.county), \(comm.state)")
                .font(.title3)
            Spacer()
                .frame(height: 10)
            HStack {
                Spacer()
                VStack {
                    Text(comm.level.uppercased())
                        .font(.largeTitle)
                    Text("Community Level")
                        .font(.caption2)
                }
                Spacer()
                VStack {
                    Text(trans.level.uppercased())
                        .font(.largeTitle)
                    Text("Transmission Level")
                        .font(.caption2)
                }
                Spacer()
            }
            Spacer()
                .frame(height: 20)
            ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(trans.historical) { historicalTrans in
                        HistoricalTransmissionView(trans: historicalTrans)
                    }
                }
            }
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(comm.historical) { historicalComm in
                        HistoricalCardView(comm: historicalComm)
                    }
                }
                Divider()
                CommunityDetailsView(comm: comm)
                    .padding([.leading, .trailing])
                Divider()
                TransmissionDetailsView(trans: trans)
                    .padding([.leading, .trailing, .bottom])
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(comm: CommunityData.exampleData.first!, trans: TransmissionData.exampleData.first!)
    }
}

//
//  PageView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct PageView: View {
    @ObservedObject var loc: Location
    var body: some View {
        VStack {
            Text("\(loc.county), \(loc.state.asShortStateName)")
                .font(.title3)
            Spacer()
                .frame(height: 10)
            HStack {
                Spacer()
                VStack {
                    Text(loc.comm.level.uppercased())
                        .font(.largeTitle)
                    Text("Community Level")
                        .font(.caption2)
                }
                Spacer()
                VStack {
                    Text(loc.trans.level.uppercased())
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
                    ForEach(loc.trans.historical) { historicalTrans in
                        HistoricalTransmissionView(trans: historicalTrans)
                    }
                }
            }
            Divider()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(loc.comm.historical) { historicalComm in
                        HistoricalCommunityView(comm: historicalComm)
                    }
                }
                Divider()
                Text("Updated weekly")
                    .font(.body)
                CommunityDetailsView(comm: loc.comm)
                    .padding([.leading, .trailing])
                Divider()
                Text("Updated daily")
                    .font(.body)
                TransmissionDetailsView(trans: loc.trans)
                    .padding([.leading, .trailing, .bottom])
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(loc: Location.exampleWithData)
    }
}

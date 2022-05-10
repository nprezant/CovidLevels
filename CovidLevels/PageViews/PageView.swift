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
                    Text("\(loc.comm.dateUpdated.formatted(dateStyle: .medium))")
                        .font(.caption2)
                }
                Spacer()
                VStack {
                    Text(loc.trans.level.uppercased())
                        .font(.largeTitle)
                    Text("Transmission Level")
                        .font(.caption2)
                    Text("\(loc.trans.date.formatted(dateStyle: .medium))")
                        .font(.caption2)
                }
                Spacer()
            }
            Spacer()
                .frame(height: 20)
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Based on the community level, the CDC recommends...")
                        .font(.body)
                }
                Spacer()
                    .frame(height: 20)
                CommunityDetailsView(comm: loc.comm)
                    .padding([.leading, .trailing, .bottom])
                    .id(loc.comm.id)
                VStack(spacing: 0) {
                    ForEach(loc.comm.historical) { historicalComm in
                        HistoricalCommunityView(comm: historicalComm)
                    }
                }
                VStack {
                    Text("Transmission Data")
                        .font(.body)
                    Text("(Intended for Healthcare Providers)")
                        .font(.caption2)
                }
                .padding([.top, .bottom])
                TransmissionDetailsView(trans: loc.trans)
                    .padding([.leading, .trailing, .bottom])
                    .id(loc.trans.id)
                ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(loc.trans.historical) { historicalTrans in
                            HistoricalTransmissionView(trans: historicalTrans)
                        }
                    }
                }
            }
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(loc: Location.exampleWithData)
    }
}

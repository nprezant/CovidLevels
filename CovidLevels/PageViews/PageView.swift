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
                .font(.title2)
                .padding()
            VStack {
                Text(loc.comm.level.uppercased())
                    .font(.largeTitle) // TODO make larger
                Text("Community Level")
                    .font(.caption)
                Text("\(loc.comm.dateUpdated.formatted(dateStyle: .medium))")
                    .font(.caption)
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    BulletedList(String.cdcRecommendations(level: loc.comm.level))
                    Link("More info", destination: URL(string: "https://www.cdc.gov/coronavirus/2019-ncov/your-health/covid-by-county.html")!)
                        .font(.subheadline)
                }
                .padding()
                Spacer()
                    .frame(height: 20)
                CommunityDetailsView(comm: loc.comm)
                    .padding([.leading, .trailing, .bottom])
                    .id(loc.comm.id)
                HistoricalCommunityView(comms: loc.comm.historical)
                    .padding()
                VStack {
                    Text("Transmission Data")
                        .font(.body)
                    Text("(Intended for Healthcare Providers)")
                    Text("Rolling 7 Day Average")
                }
                .font(.caption2)
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
                .padding(.bottom, 100)
            }
            .padding([.top])
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(loc: Location.exampleWithData)
    }
}

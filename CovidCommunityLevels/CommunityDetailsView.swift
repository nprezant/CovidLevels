//
//  CommunityDetailsView.swift
//  CovidCommunityLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct CommunityDetailsView: View {
    let commData: CommunityData
    var body: some View {
        VStack(spacing: 10) {
            DetailItemView(name: "Population", value: "\(commData.countyPopulation)")
            DetailItemView(name: "Cases per 100k", value: "\(commData.casesPer100k)")
            DetailItemView(name: "Hospital Admissions per 100k", value: "\(commData.hospitalAdmissionsPer100k)")
            DetailItemView(name: "Date Updated", value: "\(commData.dateUpdated.formatted())")
        }
    }
}

struct CommunityDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityDetailsView(commData: CommunityData.exampleData.first!)
    }
}

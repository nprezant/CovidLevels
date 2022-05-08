//
//  CommunityDetailsView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct CommunityDetailsView: View {
    let comm: CommunityData
    var body: some View {
        VStack(spacing: 10) {
            DetailItemView(name: "Population", value: "\(comm.countyPopulation)")
            DetailItemView(name: "Cases per 100k", value: "\(comm.covidCasesPer100k)")
            DetailItemView(name: "Hospital Admissions per 100k", value: "\(comm.covidHospitalAdmissionsPer100k)")
            DetailItemView(name: "Bed Utilization", value: "\(comm.covidInpatientBedUtilization)%")
            DetailItemView(name: "Date Updated", value: "\(comm.dateUpdated.formatted(dateStyle: .medium))")
        }
    }
}

struct CommunityDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityDetailsView(comm: CommunityData.exampleData.first!)
    }
}

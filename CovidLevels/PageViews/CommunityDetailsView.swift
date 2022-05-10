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
        LazyVGrid(columns: Array(repeating: GridItem.init(.flexible()), count: 2)) {
            DetailItemView(name: "Population", value: "\(comm.countyPopulation)")
            DetailItemView(name: "Inpatient Bed Utilization", value: "\(comm.covidInpatientBedUtilization)%")
            DetailItemView(name: "Cases per 100k", value: "\(comm.covidCasesPer100k)")
            DetailItemView(name: "Hospital Admissions per 100k", value: "\(comm.covidHospitalAdmissionsPer100k)")
        }
    }
}

struct CommunityDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityDetailsView(comm: CommunityData.exampleData.first!)
    }
}

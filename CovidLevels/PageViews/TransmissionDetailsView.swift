//
//  TransmissionDetailsView.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import SwiftUI
import UIKit

struct TransmissionDetailsView: View {
    let trans: TransmissionData
    var body: some View {
        VStack(spacing: 10) {
            let newCases = trans.newCasesPer100kLast7Days != nil ? "\(trans.newCasesPer100kLast7Days ?? -1)" : "<10"
            DetailItemView(name: "New cases per 100k, last 7 days", value: newCases)
            DetailItemView(name: "Positive tests (NAAT), last 7 days", value: "\(trans.percentPositiveTestsLast7Days)%")
//            DetailItemView(name: "Report date", value: "\(trans.date.formatted(dateStyle: .medium))")
        }
    }

}

struct TransmissionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransmissionDetailsView(trans: TransmissionData.exampleData.first!)
    }
}

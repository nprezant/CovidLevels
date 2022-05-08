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
//            var newCases: String = "<10"
//            if let newCasesPer100kLast7Days = trans.newCasesPer100kLast7Days {
//                newCases = "\(newCasesPer100kLast7Days)"=
//            }
            let newCases = trans.newCasesPer100kLast7Days != nil ? "\(trans.newCasesPer100kLast7Days ?? -1)" : "<10"
            DetailItemView(name: "New cases per 100k, last 7 days (daily)", value: newCases)
            DetailItemView(name: "Positive tests (NAAT), last 7 days (daily)", value: "\(trans.percentPositiveTestsLast7Days)%")
            DetailItemView(name: "Date Updated", value: "\(trans.date.formatted(dateStyle: .medium))")
        }
    }

}

struct TransmissionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransmissionDetailsView(trans: TransmissionData.exampleData.first!)
    }
}

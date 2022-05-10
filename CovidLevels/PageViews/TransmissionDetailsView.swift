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
        LazyVGrid(columns: Array(repeating: GridItem.init(.flexible()), count: 2)) {
            let newCases = trans.newCasesPer100kLast7Days != nil ? "\(trans.newCasesPer100kLast7Days!)" : "<10"
            DetailItemView(name: "New cases per 100k", value: newCases)
            DetailItemView(name: "Positive tests (NAAT)", value: "\(trans.percentPositiveTestsLast7Days)%")
        }
    }

}

struct TransmissionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransmissionDetailsView(trans: TransmissionData.exampleData.first!)
    }
}

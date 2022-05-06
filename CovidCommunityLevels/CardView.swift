//
//  CardView.swift
//  CovidCommunityLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct CardView: View {
    let commData: CommunityData
    var body: some View {
        HStack {
            Text(commData.healthServiceArea)
                .font(.body)
            Spacer()
            Text(commData.level)
                .font(.body.smallCaps())
                .padding()
        }
        .foregroundColor(.primary)
        .padding(.leading).padding(.trailing)
        .background(commData.levelColor())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(commData: CommunityData.exampleData.first!)
    }
}

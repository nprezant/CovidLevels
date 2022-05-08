//
//  DetailItemView.swift
//  CovidLevels
//
//  Created by Noah on 5/6/22.
//

import SwiftUI

struct DetailItemView: View {
    @State var name: String
    @State var value: String
    
    var body: some View {
        VStack {
            HStack {
                Text(name)
                    .font(.caption2.smallCaps())
                Spacer()
            }
            HStack {
                Text(value)
                    .font(.title3)
                Spacer()
            }
        }
    }
}

struct DetailItemView_Previews: PreviewProvider {
    static var previews: some View {
        DetailItemView(name: "Population", value: "365899")
    }
}

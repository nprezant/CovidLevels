//
//  SearchItemView.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import SwiftUI

fileprivate struct LabelCharacter : Identifiable {
    let id = UUID()
    let character: String
    let isMatch: Bool
}

struct SearchItemView: View {
    let item: SearchItem
    var label: String { item.label }
    var searchText: String
    private var labelCharacters: [LabelCharacter] {
        let matchingRanges = label.ranges(of: searchText, options: .caseInsensitive)
        var labelChars: [LabelCharacter] = []
        for index in label.indices {
            let c = String(label[index])
            let isMatch = matchingRanges.contains(where: { $0.contains(index) })
            let labelChar = LabelCharacter(character: c, isMatch: isMatch)
            labelChars.append(labelChar)
        }
        return labelChars
    }
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(labelCharacters) { labelChar in
                    Text(labelChar.character)
                        .fontWeight(labelChar.isMatch ? .bold : .regular)
                        .lineLimit(1)
                        .padding(0)
                }
                Spacer()
            }
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    static var previews: some View {
        let searchText = "Co"
        VStack {
            SearchItemView(item: SearchItem(location: .example), searchText: searchText)
            SearchItemView(item: SearchItem(location: Location(state: "Colorado", county: "This is a really long county name of some address, Larimer County, Colorado")), searchText: searchText)
        }
    }
}

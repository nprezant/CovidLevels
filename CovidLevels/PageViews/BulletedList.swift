//
//  BulletedList.swift
//  CovidLevels
//
//  Created by Noah on 6/8/22.
//

import SwiftUI

struct BulletedList: View {
    init(_ items: [String]) {
        self.items = items
    }
    let items: [String]
    let bulletSymbol = "\u{2022}"
    var body: some View {
        let bulletWidth = bulletSymbol.width(withConstrainedHeight: .greatestFiniteMagnitude, font: .preferredFont(forTextStyle: .body))
        let cols: [GridItem] = [
            .init(.flexible(maximum: bulletWidth * 3), spacing: 0, alignment: .top),
            .init(.flexible(), spacing: 10, alignment: .leading),
        ]
        let rowSpacing = "u".width(withConstrainedHeight: .greatestFiniteMagnitude, font: .preferredFont(forTextStyle: .body)) / 2
        LazyVGrid(columns: cols, spacing: rowSpacing) {
            ForEach(items, id: \.self) { item in
                Text(bulletSymbol)
                Text(item)
            }
            .font(.body)
        }
    }
}

struct BulletedList_Previews: PreviewProvider {
    static var previews: some View {
        BulletedList(String.cdcRecommendations(level: "high"))
    }
}

//
//  Modifiers.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation
import SwiftUI

struct Background: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        ZStack {
            content
            color.ignoresSafeArea()
        }
    }
}

extension View {
    func backgroundCompatible(_ color: Color) -> some View {
        modifier(Background(color: color))
    }
}

extension CGFloat {
    func clamped(_ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        return Swift.max(lower, Swift.min(upper, self))
    }
}

struct Deletable: ViewModifier {
    var onDelete: (() -> Void)? = nil
    @State private var offset = CGSize.zero
    func body(content: Content) -> some View {
        // todo use geometry reader...
        ZStack(alignment: .trailing) {
            VStack {
                Text("Delete")
                    .foregroundColor(.white)
            }
            .background(Color.red)
            .offset(x: (40 + offset.width / 2).clamped(0, 40), y: 0)
            .onTapGesture {
                withAnimation {
                    offset = CGSize.zero
                }
                onDelete?()
            }
            content
                .offset(x: offset.width.clamped(-80, 0), y: 0)
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation {
                        offset = gesture.translation
                    }
                }
                .onEnded { _ in
                    if abs(offset.width) >= 80 {
                        // leave the translation, option to be deleted
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        )
    }
}

extension View {
    func deletable(onDelete: (() -> Void)? = nil) -> some View {
        modifier(Deletable(onDelete: onDelete))
    }
}

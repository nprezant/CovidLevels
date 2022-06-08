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

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeObserver: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.background(sizeView)
    }
}

extension View {
    func observesSize() -> some View {
        modifier(SizeObserver())
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
    @State private var sz = CGSize.zero
    var slideWidth: CGFloat {
        return sz.width * 1/5
    }
    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            Text("Delete")
                .foregroundColor(.white)
                .frame(width: slideWidth, height: sz.height, alignment: .center)
                .background(Color.red)
                .offset(x: (slideWidth / 2 + offset.width / 2).clamped(0, slideWidth / 2), y: 0)
                .onTapGesture {
                    withAnimation {
                        offset = CGSize.zero
                    }
                    onDelete?()
                }
            content
                .offset(x: offset.width.clamped(-slideWidth, 0), y: 0)
                .observesSize()
        }
        .onPreferenceChange(SizePreferenceKey.self) {
            print("Incoming deletable item size \($0)")
            sz = $0
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation {
                        offset = gesture.translation
                    }
                }
                .onEnded { _ in
                    if abs(offset.width) >= slideWidth {
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

struct FloatingButton: ViewModifier {
    var imageSystemName: String
    var action: (() -> Void)? = nil
    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { action?() }) {
                        Image(systemName: imageSystemName)
                            .font(.title)
                            .padding()
                            .background(Color.white.opacity(1))
                            .clipShape(Capsule())
                    }
                    .shadow(radius: 10)
                }
            }
            .padding()
        }
    }
}

extension View {
    func floatingButton(imageSystemName: String = "question.mark", action: (() -> Void)? = nil) -> some View {
        modifier(FloatingButton(imageSystemName: imageSystemName, action: action))
    }
}

//
//  SearchBar.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import SwiftUI

// UISearchBar port
// https://developer.apple.com/videos/play/wwdc2019/231/
// https://stackoverflow.com/questions/56608996/swiftui-search-in-list-header
struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var isFirstResponder: Bool = false

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        var didBecomeFirstResponder: Bool? = nil
        var didResignFirstResponder: Bool? = nil

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal;
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
        
        // Manage focus state
        if isFirstResponder && context.coordinator.didBecomeFirstResponder != true {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
            context.coordinator.didResignFirstResponder = false
        } else if !isFirstResponder && context.coordinator.didResignFirstResponder != true {
            uiView.resignFirstResponder()
            context.coordinator.didResignFirstResponder = true
            context.coordinator.didBecomeFirstResponder = false
        }
    }
}

//
//  CrosswalkService.swift
//  CovidLevels
//
//  Created by Noah on 5/21/22.
//

import Foundation

class CrosswalkService {
    static let shared = CrosswalkService()
    private init() {}
    
    private var isStarting: Bool = false
    private var isStarted: Bool = false
    private var isSearching: Bool = false
    private var toSearch: SearchTerm? = nil
    private var crosswalkRows: [Crosswalk] = []
    
    func start() {
        if isStarted || isStarting { return }
        isStarting = true
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            crosswalkRows = readCrosswalkFile()
            isStarted = true
            findFromQueue()
        }
    }
    
//    struct SearchTerm {
//        let regex: String
//        let limit: Int
//        let compareWith: ((Crosswalk) -> [String]) // Values in the crosswalk to compare to
//        let completion: (([Crosswalk]) -> Void)
//
//        init(text: String, type: SearchType, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
//            let (regex, compareWith) = type.info(text: text)
//            self.regex = regex
//            self.limit = limit
//            self.compareWith = compareWith
//            self.completion = completion
//        }
//    }
//
//    func find(text: String, type: SearchType, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
//        find(SearchTerm(text: text, type: type, limit: limit, completion: completion))
//    }
    
    struct SearchTerm {
        let text: String
        let types: Set<SearchType>
        let limit: Int
        let completion: (([Crosswalk]) -> Void)
    }

    func find(text: String, types: Set<SearchType>, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
        find(SearchTerm(text: text, types: types, limit: limit, completion: completion))
    }
    
//    struct SearchTerm {
//        let text: String
//        let types: SearchVariables
//        let limit: Int
//        let completion: (([Crosswalk]) -> Void)
//
//        init(text: String, types: SearchVariables, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
//            self.text = text
//            self.limit = limit
//            self.types = types
//            self.completion = completion
//        }
//    }
//
//    func find(text: String, types: SearchVariables, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
//        find(SearchTerm(text: text, types: types, limit: limit, completion: completion))
//    }
    
    func find(_ st: SearchTerm) {
        // Cannot start a find operation if no data is loaded or if service is currently finding something else
        // Instead, queue the search to be looked at next
        if !isStarted || isSearching {
            print("Queueing search term. Search is currently running or service is stopped.")
            toSearch = st
            return
        }
        
        isSearching = true
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let found = findCore(st)
            isSearching = false
            st.completion(Array(found))
            findFromQueue()
        }
    }
    
    private func findCore(_ st: SearchTerm) -> Set<Crosswalk> {
        var found: Set<Crosswalk> = []
        let infos = st.types.map{ $0.info(text: st.text) }
        for cw in crosswalkRows {
            let compareData = infos.map { ($0.getCompareField(cw), $0.regex, $0.includeCrosswalk) }
            let matches = compareData.filter{ field, regex, _ in field.matches(regex: regex, options: .caseInsensitive) }
            if !matches.isEmpty {
                let (success, item) = found.insert(cw)
                if success, let match = matches.first {
                    item.foundWith = match.2 ? match.0 : nil
                }
                if found.count >= st.limit {
                    break
                }
            }
        }
        return found
    }
    
    private func findFromQueue() {
        if let st = toSearch {
            toSearch = nil
            find(st)
        }
    }
    
    enum SearchType : Int {
        case zip
        case city
        case county
        
        func info(text: String) -> (regex: String, getCompareField: ((Crosswalk) -> String), includeCrosswalk: Bool) {
            switch self {
            case .zip:
                return ("\(text)\\d*", {$0.zctaCode}, true)
            case .city:
                return ("\(text).*", {$0.zctaName}, true)
            case .county:
                return ("\(text).*", {$0.county}, false)
            }
        }
    }
}

fileprivate func readCrosswalkFile() -> [Crosswalk] {
    print("Reading crosswalk file")
    
    guard let filepath = Bundle.main.path(forResource: "crosswalk", ofType: "txt") else {
        print("Cannot find county crosswalk file")
        return []
    }
    
    guard let data = try? String(contentsOfFile: filepath) else {
        print("Cannot read crosswalk file: \(filepath)")
        return []
    }

    var crosswalks: [Crosswalk] = []
    
    for line in data.components(separatedBy: "\r\n")[1...] {
        if let crosswalk = Crosswalk(fromLine: String(line)) {
            crosswalks.append(crosswalk)
        }
    }
    
    return crosswalks
}

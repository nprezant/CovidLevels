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
    
    struct SearchTerm {
        let regex: String
        let limit: Int
        let getter: ((Crosswalk) -> String)
        let completion: (([Crosswalk]) -> Void)
    }
    
    private func find(_ st: SearchTerm) {
        // Cannot start a find operation if no data is loaded or if service is currently finding something else
        // Instead, queue the search to be looked at next
        if !isStarted || isSearching {
            print("Queueing search term. Search is currently running or service is stopped.")
            toSearch = st
            return
        }
        
        isSearching = true
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            var found: Set<Crosswalk> = []
            for cw in crosswalkRows {
                if st.getter(cw).matches(regex: st.regex, options: .caseInsensitive) {
                    found.insert(cw)
                    if found.count >= st.limit {
                        break
                    }
                }
            }
            isSearching = false
            st.completion(Array(found))
            findFromQueue()
        }
    }
    
    private func findFromQueue() {
        if let st = toSearch {
            toSearch = nil
            find(st)
        }
    }
    
    enum SearchType {
        case zip
        case city
        case county
        
        func info(text: String) -> (regex: String, crosswalkGetter: ((Crosswalk) -> String)) {
            switch self {
            case .zip:
                return ("\(text)\\d*", {$0.zctaCode})
            case .city:
                return ("\(text).*", {$0.zctaName})
            case .county:
                return ("\(text).*", {$0.county})
            }
        }
    }
    
    func find(text: String, type: SearchType, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
        let (regex, getter) = type.info(text: text)
        find(SearchTerm(regex: regex, limit: limit, getter: getter, completion: completion))
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

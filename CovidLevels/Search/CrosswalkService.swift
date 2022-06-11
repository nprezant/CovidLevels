//
//  CrosswalkService.swift
//  CovidLevels
//
//  Created by Noah on 5/21/22.
//

import Foundation

class CrosswalkService {
    static let shared = CrosswalkService()
    private init() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.start()
        }
    }
    
    private var isStarting: Bool = false
    private var isStarted: Bool = false
    private var isSearching: Bool = false
    private var toSearch: [SearchTerm] = []
    private var crosswalkRows: [Crosswalk] = []
    
    private func start() {
        if isStarted || isStarting { return }
        isStarting = true
        crosswalkRows = readCrosswalkFile()
        isStarted = true
        emptyQueue()
    }
    
    struct SearchTerm {
        let text: String
        let types: Set<SearchType>
        let limit: Int
        let completion: (([Crosswalk]) -> Void)
    }

    func find(text: String, types: Set<SearchType>, limit: Int, completion: @escaping (([Crosswalk]) -> Void)) {
        find(SearchTerm(text: text, types: types, limit: limit, completion: completion))
    }
    
    func find(_ st: SearchTerm) {
        // Cannot start a find operation if no data is loaded or if service is currently finding something else
        // Instead, queue the search to be looked at next
        if toSearch.isEmpty { toSearch.append(st) }
        else { toSearch[0] = st }
        emptyQueue()
    }
    
    private func emptyQueue() {
        if !isStarted && isSearching || toSearch.isEmpty {
            return
        }
        
        isSearching = true
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            while !toSearch.isEmpty {
                let st = toSearch.remove(at: 0)
                let found = findCore(st)
                st.completion(Array(found))
            }
            isSearching = false
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

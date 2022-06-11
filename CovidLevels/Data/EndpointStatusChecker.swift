//
//  DataUpdateChecker.swift
//  CovidLevels
//
//  Created by Noah on 5/22/22.
//

import Foundation

class EndpointStatusChecker {
    
    static let shared = EndpointStatusChecker()
    private init() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.start()
        }
    }
    
    private var isStarting: Bool = false
    private var isStarted: Bool = false
    private var isChecking: Bool = false
    private var toCheck: [CheckItem] = []
    
    private var endpoints: [String:EndpointStatus] = [:]
    private static let url = FileLocations.documentsFolder.appendingPathComponent("endpointStatus.json")
    private static let minCheckInterval: TimeInterval = .minutes(10)
    
    enum StatusCode {
        case UpToDate
        case OutOfDate
    }
    
    struct EndpointStatus : Codable {
        let id: String
        let lastUpdated: Date
        let lastChecked: Date
    }
    
    struct CheckItem {
        let id: String
        let against: Date
        let completion: ((StatusCode) -> Void)
    }
    
    private func start() {
        isStarting = true
        endpoints = loadJson(url: EndpointStatusChecker.url, type: Dictionary<String,EndpointStatus>.self) ?? [:]
        isStarting = false
        isStarted = true
        emptyQueue()
    }
    
    func check(id: String, against date: Date, completion: @escaping ((StatusCode) -> Void)) {
        check(CheckItem(id: id, against: date, completion: completion))
    }
    
    private func check(_ item: CheckItem) {
        toCheck.append(item)
        emptyQueue()
    }
    
    private func emptyQueue() {
        if !isStarted || isChecking || toCheck.isEmpty {
            return
        }
        
        isChecking = true
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            while !toCheck.isEmpty {
                let checkItem = toCheck.remove(at: 0)
                checkCore(checkItem)
            }
            isChecking = false
        }
    }
        
    private func checkCore(_ item: CheckItem) {
        guard let status = check(id: item.id) else {
        // If no status can be found, this is a programming error. Assume out of date.
            print("Endpoint \(item.id) status not found")
            item.completion(.OutOfDate)
            return
        }
        
        // If the endpoint was updated more recently than the date we're comparing against, we're out of date.
        if status.lastUpdated.timeIntervalSince1970 > item.against.timeIntervalSince1970 {
            item.completion(.OutOfDate)
        } else {
            item.completion(.UpToDate)
        }
    }
    
    private func check(id: String) -> EndpointStatus? {
        // If this endpoint is already known and it has been checked recently, there is no need to do anything
        if let endpoint = endpoints[id] {
            if endpoint.lastChecked.timeIntervalSinceNow > -EndpointStatusChecker.minCheckInterval {
                print("Endpoint \(id) checked for update recently. Not re-checking.")
                return endpoint
            } else {
                print("Endpoint \(id) not checked for update recently. Re-checking.")
            }
        }

        // The endpoint is not known or it hasn't been checked in a while. Required to check the server.
        guard let date = checkLastServerUpdate(id: id) else {
            print("No date found from server for endpoint \(id)")
            return nil
        }
        
        print("Endpoint \(id) was last updated: \(date)")
        let ep = EndpointStatus(id: id, lastUpdated: date, lastChecked: Date.now)
        endpoints[id] = ep
        save()
        return ep
    }
    
    private func checkLastServerUpdate(id: String) -> Date? {
        var urlComponents = URLComponents(string: "https://api.us.socrata.com/api/catalog/v1")!
        urlComponents.queryItems = [
            URLQueryItem(name: "ids", value: id),
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setSocrataHeader()
        
        // Set up dispatch group to allow waiting for the url request to complete
        let group = DispatchGroup()
        group.enter()
        
        var endpointLastUpdate: Date? = nil

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = json["results"] as? Array<[String: Any]>,
               let resource = results.first?["resource"] as? [String: Any],
               let updatedAt = resource["updatedAt"] as? String {
                endpointLastUpdate = Date.fromSocrataFloatingTimestamp(updatedAt)
            }
            group.leave()
        }

        // Begin task
        task.resume()

        // Wait for task to complete
        group.wait()
        
        return endpointLastUpdate
    }
    
    private func save() {
        // Write endpoint status to file.
        print("Saving endpoints: \(EndpointStatusChecker.url)")
        guard let data = try? JSONEncoder().encode(endpoints.self) else {
            print("Error saving endpoints.")
            return
        }
        guard let _ = try? data.write(to: EndpointStatusChecker.url) else {
            print("Error writing to endpoints file.")
            return
        }
    }
    
}

func loadJson<T>(url: URL, type: T.Type) -> T? where T : Decodable {
    guard let data = try? Data(contentsOf: url) else {
        print("File does not exist: \(url)")
        return nil
    }
    guard let decoded = try? JSONDecoder().decode(type, from: data) else {
        print("Error decoding file. Removing file. \(url)")
        try? FileManager.default.removeItem(at: url)
        return nil
    }
    return decoded
}

//
//  DataUpdateChecker.swift
//  CovidLevels
//
//  Created by Noah on 5/22/22.
//

import Foundation

class EndpointStatusChecker {
    
    static let shared = EndpointStatusChecker()
    private init() {}
    
    private var endpoints: [String:EndpointStatus] = [:]
    private static let url = FileLocations.documentsFolder.appendingPathComponent("endpointStatus.json")
    private static let minCheckInterval: TimeInterval = .minutes(5)
    
    enum StatusCode {
        case UpToDate
        case OutOfDate
    }
    
    struct EndpointStatus : Codable {
        let id: String
        let lastUpdated: Date
        let lastChecked: Date
    }
    
    func check(id: String, against date: Date, completion: @escaping ((StatusCode) -> Void)) {
        check(id: id) { status in
            // If no status can be found, this is a programming error. Assume out of date.
            guard let status = status else {
                print("No endpoint status could be found for id \(id)")
                completion(.OutOfDate)
                return
            }
            
            // If the endpoint was updated more recently than the date we're comparing against, we're out of date.
            if status.lastUpdated.timeIntervalSince1970 > date.timeIntervalSince1970 {
                completion(.OutOfDate)
            } else {
                completion(.UpToDate)
            }
        }
    }
    
    func check(id: String, completion: @escaping ((EndpointStatus?) -> Void)) {
        // Load endpoints if needed
        if endpoints.isEmpty {
            endpoints = loadJson(url: EndpointStatusChecker.url, type: Dictionary<String,EndpointStatus>.self) ?? [:]
        }
        
        // If this endpoint is already known and it has been checked recently, there is no need to do anything
        if let endpoint = endpoints[id] {
            if endpoint.lastChecked.timeIntervalSinceNow > -EndpointStatusChecker.minCheckInterval {
                print("Endpoint checked recently. No need to re-check.")
                completion(endpoint)
                return
            }
        }

        // The endpoint is not known or it hasn't been checked in a while. Required to check the server.
        checkLastServerUpdate(id: id) { [self] date in
            print("Rechecked endpoint status. Last updated \(String(describing: date))")
            guard let date = date else {
                completion(nil)
                return
            }
            let ep = EndpointStatus(id: id, lastUpdated: date, lastChecked: Date.now)
            endpoints[id] = ep
            save()
            completion(ep)
        }
    }
    
    private func checkLastServerUpdate(id: String, completion: @escaping ((Date?) -> Void)) {
        var urlComponents = URLComponents(string: "https://api.us.socrata.com/api/catalog/v1")!
        urlComponents.queryItems = [
            URLQueryItem(name: "ids", value: id),
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.setSocrataHeader()

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = json["results"] as? Array<[String: Any]>,
               let resource = results.first?["resource"] as? [String: Any],
               let updatedAt = resource["updatedAt"] as? String {
                completion(Date.fromSocrataFloatingTimestamp(updatedAt))
            } else {
                completion(nil)
            }
        }

        task.resume()
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

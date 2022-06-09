//
//  DataCache.swift
//  CovidLevels
//
//  Created by Noah on 5/22/22.
//

import Foundation

struct DataCache<T: Codable> : Codable {
    let modificationDate: Date
    let data: T
}

class DataCacheService {
    private static func makeUrl(_ name: String) -> URL {
        return FileLocations.documentsFolder.appendingPathComponent(name)
    }
    
    static func getCache<T>(_ name: String) -> DataCache<T>? {
        let url = makeUrl(name)
        guard let data = try? Data(contentsOf: url) else {
            print("Cache file does not exist: \(name)")
            return nil
        }
        guard let dataCache = try? JSONDecoder().decode(DataCache<T>.self, from: data) else {
            print("Error decoding cache file. Removing file. File: \(name)")
            try? FileManager.default.removeItem(at: url)
            return nil
        }
        print("Found cache \(name)")
        return dataCache
    }
    
    static func save<T: Codable>(_ data: T, name: String) {
        print("Saving cache '\(name)'")
        let date = Date.now
        let dataCache = DataCache(modificationDate: date, data: data)
        guard let encodedData = try? JSONEncoder().encode(dataCache.self) else {
            print("Error encoding \(name) data cache.")
            return
        }
        guard let _ = try? encodedData.write(to: makeUrl(name)) else {
            print("Error writing to data cache file.")
            return
        }
    }
}

//extension DataCacheService {
//    static func sync<T: SocrataDataSource>(state: String, county: String, source: T) -> some SocrataDataSource {
//        // Name of stored data
//        let cacheName = "\(state)-\(county).cache".replacingOccurrences(of: " ", with: "-")
//        
//        // Read in stored data. If there is no data stored, we'll need to update
//        guard let cache : DataCache<T> = DataCacheService.getCache(cacheName) else {
//            // Get update
//            if let data: T = T.requestUpdate(state: state, county: county) {
//                DataCacheService.save(data, name: cacheName)
//                return data
//            } else {
//                return T() // Update failed
//            }
//        }
//        
//        // Okay, so we have some stored data.
//        // If it is up to date we can use it.
//        // If it is out of date we'll need to update it.
//        let group = DispatchGroup()
//        group.enter()
//        
//        var data: T? = nil
//        
//        EndpointStatusChecker.shared.check(id: T.socrataEndpointId, against: cache.modificationDate) { status in
//            switch status {
//            case .UpToDate:
//                data = cache.data
//            case .OutOfDate:
//                data = T.requestUpdate(state: state, county: county)
//                if let data = data {
//                    DataCacheService.save(data, name: cacheName)
//                }
//            }
//            group.leave()
//        }
//        
//        group.wait()
//        
//        return data ?? T()
//    }
//}
//

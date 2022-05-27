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
        print("Looking for cache '\(name)'")
        let url = makeUrl(name)
        guard let data = try? Data(contentsOf: url) else {
            print("Cache file does not exist.")
            return nil
        }
        guard let dataCache = try? JSONDecoder().decode(DataCache<T>.self, from: data) else {
            print("Error decoding cache file. Removing file.")
            try? FileManager.default.removeItem(at: url)
            return nil
        }
        return dataCache
    }
    
    static func save<T: Codable>(_ data: T, name: String) {
        print("Saving cache '\(name)'")
        let date = Date.today
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


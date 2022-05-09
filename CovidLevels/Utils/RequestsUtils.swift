//
//  RequestsUtils.swift
//  CovidLevels
//
//  Created by Noah on 5/9/22.
//

import Foundation

extension Dictionary where Key == String {
    func extract(_ key: String) -> String? {
        guard let value = self[key] as? String else {
            debugPrint("Value missing from dictionary: \(key)")
            return nil
        }
        return value
    }
    
    func extract<T>(_ key: String, conversionFunc: (String)->T?) -> T? {
        guard let value = extract(key) else {
            return nil
        }
        return conversionFunc(value)
    }
}

extension Date {
    /// Socrata dates are ISO8601 Times with no timezone offset and three sig figs of millisecond precision
    /// https://dev.socrata.com/docs/datatypes/floating_timestamp.html
    /// https://stackoverflow.com/questions/36861732/convert-string-to-date-in-swift
    static func fromSocrataFloatingTimestamp(_ isoDate: String) -> Date? {
        // Interpret the iso date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        guard let date = dateFormatter.date(from: isoDate) else { return nil }

        // Now for the current timezone
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return calendar.date(from: components)
    }
}

extension URLRequest {
    mutating func setSocrataHeader() {
        self.setValue("X-App-Token", forHTTPHeaderField: "f3fjentqIxjN6C9UkGM3TfzjD")
    }
}

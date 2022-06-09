//
//  Utils.swift
//  CovidLevels
//
//  Created by Noah on 5/8/22.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    init(level: String) {
        switch level.lowercased() {
        case "low":
            self.init(hex: 0x90ee90)
        case "med","medium","moderate":
            self.init(hex: 0xeed971)
        case "substantial":
            self.init(hex: 0xff9d5c)
        case "high":
            self.init(hex: 0xff7f7f)
        default:
            self.init(hex: 0xd3d3d3)
        }
    }
}

extension String {
    static func cdcRecommendations(level: String) -> [String] {
        switch level.lowercased() {
        case "low":
            return [
                "Stay up to date with COVID-19 vaccines",
                "Get tested if you have symptoms",
            ]
        case "medium":
            return [
                "If you are at high risk for severe illness, talk to your healthcare provider about whether you need to wear a mask and take other precautions",
                "Stay up to date with COVID-19 vaccines",
                "Get tested if you have symptoms",
            ]
        case "high":
            return [
                "Wear a mask indoors in public",
                "Stay up to date with COVID-19 vaccines",
                "Get tested if you have symptoms",
                "Additional precautions may be needed for people at high risk for severe illness",
            ]
        default:
            return [
                "No CDC recommendations found for the '\(level)' level.",
            ]
        }
    }
}

extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func formatted(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    static var today: Date {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        return calendar.date(from: components)!
    }
    
    static var now: Date {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        return calendar.date(from: components)!
    }
    
    var friendlyLastUpdatedMessage: String {
        let justNowTolerance: TimeInterval = 60 // seconds
        let longTimeAgo: TimeInterval = .weeks(4)
        let delta = -1 * timeIntervalSinceNow
        
        // Handle special cases
        if delta < justNowTolerance {
            return "just now"
        } else if delta > longTimeAgo {
            return "a long time ago"
        }
        
        // Handle minutes, hours, days, weeks
        let count: TimeInterval
        let unit: String
        if delta < .minutes(1) {
            count = delta
            unit = "second"
        } else if delta < .hours(1) {
            count = delta / .minutes(1)
            unit = "minute"
        } else if delta < .days(1) {
            count = delta / .hours(1)
            unit = "hour"
        } else if delta < .weeks(1) {
            count = delta / .days(1)
            unit = "day"
        } else {
            count = delta / .weeks(1)
            unit = "week"
        }
        
        let shortenedCount = Int(count)
        return "\(shortenedCount) \(unit)\(shortenedCount.plurality) ago"
    }
}

extension Int {
    var plurality: String {
        return self == 1 ? "" : "s"
    }
}

extension String {
    var length: Int {
        return count
    }
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    func matches(regex: String, options: CompareOptions = []) -> Bool {
        return self.range(of: regex, options: options.union(.regularExpression), range: nil, locale: nil) != nil
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

struct FileLocations {
    public static var documentsFolder: URL {
        // Apple's eskimo says this try! is okay
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}

extension Sequence where Iterator.Element: Hashable {
    func distinct() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

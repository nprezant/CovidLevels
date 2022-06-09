//
//  LastUpdatedService.swift
//  CovidLevels
//
//  Created by Noah on 6/9/22.
//

import Foundation

class LastUpdatedService : ObservableObject {
    @Published var lastUpdatedMessage: String = "unknown"
    private var lastUpdatedDate: Date? = nil
    private var timer: Timer? = nil
    
    func registerChange() {
        lastUpdatedDate = Date.now
        if timer == nil {
            timer = .scheduledTimer(withTimeInterval: 15, repeats: true, block: {_ in self.refresh()})
        }
        timer?.fire()
    }
    
    private func refresh() {
        let newMessage = lastUpdatedDate?.friendlyLastUpdatedMessage ?? "unknown"
        if newMessage != lastUpdatedMessage {
            lastUpdatedMessage = newMessage
        }
        
        if let interval = timer?.timeInterval {
            // Check less often as time goes on
            let newInterval: TimeInterval
            if interval < .minutes(1) {
                newInterval = 15
            } else if interval < .hours(1) {
                newInterval = .minutes(1)
            } else if interval < .days(1) {
                newInterval = .hours(1)
            } else { // if interval < .weeks(1) {
                newInterval = .days(1)
            }
            
            // Only reset the timer if necessary
            if newInterval != interval {
                timer?.invalidate()
                timer = .scheduledTimer(withTimeInterval: newInterval, repeats: true, block: {_ in self.refresh()})
            }
        }
    }
}

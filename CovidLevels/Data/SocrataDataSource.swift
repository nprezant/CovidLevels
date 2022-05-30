//
//  SocrataDataSource.swift
//  CovidLevels
//
//  Created by Noah on 5/27/22.
//

import Foundation

protocol SocrataDataSource : Identifiable, Codable {
    static var socrataEndpointId: String { get }
    static var socrataEndpoint: String { get }
    init()
}

extension SocrataDataSource {
    static var socrataEndpoint: String {
        return "https://data.cdc.gov/resource/\(socrataEndpointId).json"
    }
}

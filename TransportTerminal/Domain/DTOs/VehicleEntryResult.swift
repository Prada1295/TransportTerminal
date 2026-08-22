//
//  VehicleEntryResult.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//

import Foundation

public struct VehicleEntryResult: Equatable {
    public let vehicleId: UUID
    public let plate: String
    public let timestamp: Date

    public init(
        vehicleId: UUID,
        plate: String,
        timestamp: Date
    ) {
        self.vehicleId = vehicleId
        self.plate = plate
        self.timestamp = timestamp
    }
}

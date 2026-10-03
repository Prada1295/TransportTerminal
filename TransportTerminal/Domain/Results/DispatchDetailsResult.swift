//
//  DispatchDetailsResult.swift
//  TransportTerminal
//
//  Created by Codex on 3/10/26.
//

import Foundation

public struct DispatchDetailsResult: Identifiable, Equatable {
    public let id: UUID
    public let vehicleId: UUID
    public let vehiclePlate: String
    public let vehicleType: VehicleType
    public let routeId: UUID
    public let routeOrigin: String
    public let routeDestination: String
    public let bayId: UUID
    public let bayCode: String
    public let scheduledDeparture: Date
    public let actualDeparture: Date?
    public let status: DispatchStatus
}

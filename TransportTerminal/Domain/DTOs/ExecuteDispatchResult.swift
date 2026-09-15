//
//  VehicleDetails.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation

public struct ExecuteDispatchResult: Equatable {

    public let dispatchId: UUID
    public let vehicleId: UUID
    public let routeId: UUID
    public let bayId: UUID
    public let scheduledDeparture: Date
    public let actualDeparture: Date
    public let status: DispatchStatus

    public init(
        dispatchId: UUID,
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date,
        actualDeparture: Date,
        status: DispatchStatus
    ) {
        self.dispatchId = dispatchId
        self.vehicleId = vehicleId
        self.routeId = routeId
        self.bayId = bayId
        self.scheduledDeparture = scheduledDeparture
        self.actualDeparture = actualDeparture
        self.status = status
    }
}


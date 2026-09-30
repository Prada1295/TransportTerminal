//
//  CreateDispatchResult.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 24/08/26.
//

import Foundation

public struct CreateDispatchResult: Equatable {
    public let dispatchId: UUID
    public let vehicleId: UUID
    public let routeId: UUID
    public let bayId: UUID
    public let scheduledDeparture: Date
    public let status: DispatchStatus

    public init(
        dispatchId: UUID,
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        scheduledDeparture: Date,
        status: DispatchStatus
    ) {
        self.dispatchId = dispatchId
        self.vehicleId = vehicleId
        self.routeId = routeId
        self.bayId = bayId
        self.scheduledDeparture = scheduledDeparture
        self.status = status
    }
}

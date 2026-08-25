//
//  CancelDispatchResult.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public struct CancelDispatchResult: Equatable {
    public let dispatchId: UUID
    public let vehicleId: UUID
    public let routeId: UUID
    public let bayId: UUID
    public let status: DispatchStatus

    public init(
        dispatchId: UUID,
        vehicleId: UUID,
        routeId: UUID,
        bayId: UUID,
        status: DispatchStatus
    ) {
        self.dispatchId = dispatchId
        self.vehicleId = vehicleId
        self.routeId = routeId
        self.bayId = bayId
        self.status = status
    }
}

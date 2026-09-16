//
//  Dispatch.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation


public struct Dispatch: Identifiable, Equatable {
    public let id: UUID
    public let vehicleId: UUID
    public let routeId: UUID
    public let bayId: UUID
    public let scheduledDeparture: Date
    public var actualDeparture: Date?
    public var status: DispatchStatus
}

//
//  Vehicle.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public struct Vehicle: Identifiable, Equatable {
    public let id: UUID
    public var plate: String
    public var companyId: UUID
    public var type: VehicleType
    public var capacity: Int
    public var status: VehicleStatus
}

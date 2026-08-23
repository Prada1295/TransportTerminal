//
//  VehicleMovement.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public struct VehicleMovement: Identifiable {
    public let id: UUID
    public let vehicleId: UUID
    public let timestamp: Date
    public let type: MovementType
}

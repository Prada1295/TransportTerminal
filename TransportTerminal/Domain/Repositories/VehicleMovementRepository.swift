//
//  VehicleMovementRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//
import Foundation

public protocol VehicleMovementRepository {
    func save(_ movement: VehicleMovement) async throws
    func getMovements(vehicleId: UUID) async throws -> [VehicleMovement]
}

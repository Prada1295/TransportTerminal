//
//  InMemoryVehicleMovementRepository.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public actor InMemoryVehicleMovementRepository: VehicleMovementRepository {
    private var movements: [VehicleMovement]

    public init(movements: [VehicleMovement] = []) {
        self.movements = movements
    }

    public func save(_ movement: VehicleMovement) async throws {
        movements.append(movement)
    }

    public func getMovements(vehicleId: UUID) async throws -> [VehicleMovement] {
        movements.filter { $0.vehicleId == vehicleId }
    }
}

//
//  RegisterVehicleExitUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 22/08/26.
//

import Foundation

public protocol RegisterVehicleExitUseCase {
    func execute(vehicleId: UUID) async throws -> VehicleExitResult
}

public final class RegisterVehicleExit: RegisterVehicleExitUseCase {
    private let vehicleRepository: VehicleRepository
    private let movementRepository: VehicleMovementRepository

    public init(
        vehicleRepository: VehicleRepository,
        movementRepository: VehicleMovementRepository
    ) {
        self.vehicleRepository = vehicleRepository
        self.movementRepository = movementRepository
    }

    public func execute(vehicleId: UUID) async throws -> VehicleExitResult {
        guard var vehicle = try await vehicleRepository.getById(vehicleId) else {
            throw TerminalError.vehicleNotFound
        }

        guard vehicle.status != .maintenance else {
            throw TerminalError.vehicleInMaintenance
        }

        guard vehicle.status == .insideTerminal else {
            throw TerminalError.vehicleNotInsideTerminal
        }

        let movement = VehicleMovement(
            id: UUID(),
            vehicleId: vehicle.id,
            timestamp: Date(),
            type: .exit
        )

        try await movementRepository.save(movement)

        vehicle.status = .outsideTerminal
        try await vehicleRepository.update(vehicle)

        return VehicleExitResult(
            vehicleId: vehicle.id,
            plate: vehicle.plate,
            timestamp: movement.timestamp
        )
    }
}

//
//  RegisterVehicleEntryUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 21/08/26.
//

import Foundation

public protocol RegisterVehicleEntryUseCase {
    func execute(vehicleId: UUID) async throws -> VehicleEntryResult
}

public final class RegisterVehicleEntry: RegisterVehicleEntryUseCase {
    private let vehicleRepository: VehicleRepository
    private let companyRepository: CompanyRepository
    private let movementRepository: VehicleMovementRepository

    public init(
        vehicleRepository: VehicleRepository,
        companyRepository: CompanyRepository,
        movementRepository: VehicleMovementRepository
    ) {
        self.vehicleRepository = vehicleRepository
        self.companyRepository = companyRepository
        self.movementRepository = movementRepository
    }

    public func execute(vehicleId: UUID) async throws -> VehicleEntryResult {
        guard var vehicle = try await vehicleRepository.getById(vehicleId) else {
            throw TerminalError.vehicleNotFound
        }

        guard let company = try await companyRepository.getById(vehicle.companyId) else {
            throw TerminalError.companyNotFound
        }

        guard company.isActive else {
            throw TerminalError.companyInactive
        }

        guard vehicle.status != .maintenance else {
            throw TerminalError.vehicleInMaintenance
        }

        guard vehicle.status != .insideTerminal else {
            throw TerminalError.vehicleAlreadyInside
        }

        let movement = VehicleMovement(
            id: UUID(),
            vehicleId: vehicle.id,
            timestamp: Date(),
            type: .entry
        )

        try await movementRepository.save(movement)

        vehicle.status = .insideTerminal
        try await vehicleRepository.update(vehicle)

        return VehicleEntryResult(
            vehicleId: vehicle.id,
            plate: vehicle.plate,
            timestamp: movement.timestamp
        )
    }
}

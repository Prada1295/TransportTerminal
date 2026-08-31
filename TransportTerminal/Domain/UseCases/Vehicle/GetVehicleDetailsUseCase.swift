//
//  GetVehicleDetailsUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation

public protocol GetVehicleDetailsUseCase {

    func execute(
        vehicleId: UUID
    ) async throws -> VehicleDetailsDTO
}

public final class GetVehicleDetails: GetVehicleDetailsUseCase {

    private let vehicleRepository: VehicleRepository
    private let companyRepository: CompanyRepository

    public init(
        vehicleRepository: VehicleRepository,
        companyRepository: CompanyRepository
    ) {
        self.vehicleRepository = vehicleRepository
        self.companyRepository = companyRepository
    }

    public func execute(
        vehicleId: UUID
    ) async throws -> VehicleDetailsDTO {

        guard let vehicle = try await vehicleRepository.getById(vehicleId) else {
            throw TerminalError.vehicleNotFound
        }

        guard let company = try await companyRepository.getById(
            vehicle.companyId
        ) else {
            throw TerminalError.companyNotFound
        }

        return VehicleDetailsDTO(
            vehicle: vehicle,
            company: company
        )
    }
}

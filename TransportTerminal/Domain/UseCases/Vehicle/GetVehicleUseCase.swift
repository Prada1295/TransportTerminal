//
//  GetVehicleUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation

public protocol GetVehiclesUseCase {

    func execute() async throws -> [Vehicle]
}

public final class GetVehicles: GetVehiclesUseCase {

    private let vehicleRepository: VehicleRepository

    public init(
        vehicleRepository: VehicleRepository
    ) {
        self.vehicleRepository = vehicleRepository
    }

    public func execute() async throws -> [Vehicle] {

        try await vehicleRepository.getAll()
    }
}

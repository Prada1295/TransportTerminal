//
//  GetVehiclesInsideTerminalUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 24/08/26.
//

import Foundation

public protocol GetVehiclesInsideTerminalUseCase {
    func execute() async throws -> [Vehicle]
}

public final class GetVehiclesInsideTerminal: GetVehiclesInsideTerminalUseCase {
    private let vehicleRepository: VehicleRepository

    public init(vehicleRepository: VehicleRepository) {
        self.vehicleRepository = vehicleRepository
    }

    public func execute() async throws -> [Vehicle] {
        let vehicles = try await vehicleRepository.getAll()
        return vehicles.filter { $0.status == .insideTerminal }
    }
}

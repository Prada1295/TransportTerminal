//
//  DashboardViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {

    private let getVehiclesInsideTerminalUseCase: GetVehiclesInsideTerminalUseCase
    
    private let getVehiclesUseCase: GetVehiclesUseCase
    
    private(set) var vehiclesAvailableForEntry: [Vehicle] = []

    private(set) var vehiclesInsideTerminal: [Vehicle] = []

    private(set) var isLoading = false

    private(set) var errorMessage: String?

    init(
        getVehiclesInsideTerminalUseCase:
        GetVehiclesInsideTerminalUseCase, getVehiclesUseCase: GetVehiclesUseCase
    ) {
        self.getVehiclesInsideTerminalUseCase = getVehiclesInsideTerminalUseCase
        
        self.getVehiclesUseCase = getVehiclesUseCase
    }

    func loadDashboard() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {

            async let insideVehicles =
                getVehiclesInsideTerminalUseCase.execute()

            async let allVehicles =
                getVehiclesUseCase.execute()

            let (
                vehiclesInside,
                vehicles
            ) = try await (
                insideVehicles,
                allVehicles
            )

            vehiclesInsideTerminal = vehiclesInside

            vehiclesAvailableForEntry = vehicles.filter {
                $0.status == .outsideTerminal
            }

        } catch {

            vehiclesInsideTerminal = []
            vehiclesAvailableForEntry = []

            errorMessage =
                "Unable to load dashboard information."
        }
    }
}



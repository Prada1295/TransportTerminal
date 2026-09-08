//
//  RegisterVehicleExitViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 7/09/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class RegisterVehicleExitViewModel {

    private let getVehiclesInsideTerminalUseCase:
        GetVehiclesInsideTerminalUseCase

    private let registerVehicleExitUseCase:
        RegisterVehicleExitUseCase

    private(set) var vehiclesInsideTerminal: [Vehicle] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var exitResult: VehicleExitResult?

    init(
        getVehiclesInsideTerminalUseCase:
            GetVehiclesInsideTerminalUseCase,
        registerVehicleExitUseCase:
            RegisterVehicleExitUseCase
    ) {
        self.getVehiclesInsideTerminalUseCase =
            getVehiclesInsideTerminalUseCase
        self.registerVehicleExitUseCase =
            registerVehicleExitUseCase
    }

    func loadVehiclesInsideTerminal() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            vehiclesInsideTerminal =
                try await getVehiclesInsideTerminalUseCase.execute()
        } catch {
            vehiclesInsideTerminal = []
            errorMessage =
                "Unable to load vehicles inside the terminal."
        }
    }

    func registerExit(vehicleId: UUID) async {
        isLoading = true
        errorMessage = nil
        exitResult = nil

        defer {
            isLoading = false
        }

        do {
            exitResult =
                try await registerVehicleExitUseCase.execute(
                    vehicleId: vehicleId
                )
        } catch let error as TerminalError {
            handle(error)
        } catch {
            errorMessage =
                "Unable to register vehicle exit."
        }
    }

    private func handle(_ error: TerminalError) {
        switch error {
        case .vehicleNotFound:
            errorMessage = "Vehicle was not found."

        case .vehicleInMaintenance:
            errorMessage =
                "Vehicle is currently in maintenance."

        case .vehicleNotInsideTerminal:
            errorMessage =
                "Vehicle is not inside the terminal."

        default:
            errorMessage =
                "Unable to register vehicle exit."
        }
    }
}

//
//  RegisterVehicleEntryViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class RegisterVehicleEntryViewModel {

    private let registerVehicleEntryUseCase:
        RegisterVehicleEntryUseCase

    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var entryResult: VehicleEntryResult?

    init(
        registerVehicleEntryUseCase:
            RegisterVehicleEntryUseCase
    ) {
        self.registerVehicleEntryUseCase =
            registerVehicleEntryUseCase
    }

    func registerEntry(vehicleId: UUID) async {

        isLoading = true
        errorMessage = nil
        entryResult = nil

        defer {
            isLoading = false
        }

        do {

            entryResult =
                try await registerVehicleEntryUseCase.execute(
                    vehicleId: vehicleId
                )

        } catch let error as TerminalError {

            handle(error)

        } catch {

            errorMessage =
                "Unable to register vehicle entry."
        }
    }

    private func handle(_ error: TerminalError) {

        switch error {

        case .vehicleNotFound:
            errorMessage = "Vehicle was not found."

        case .companyNotFound:
            errorMessage = "Vehicle company was not found."

        case .companyInactive:
            errorMessage = "Vehicle company is inactive."

        case .vehicleInMaintenance:
            errorMessage = "Vehicle is currently in maintenance."

        case .vehicleAlreadyInside:
            errorMessage = "Vehicle is already inside the terminal."

        default:
            errorMessage = "Unable to register vehicle entry."
        }
    }
}

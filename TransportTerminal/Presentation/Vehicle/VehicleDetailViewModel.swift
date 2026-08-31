//
//  VehicleDetailViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class VehicleDetailViewModel {

    private let getVehicleDetailsUseCase: GetVehicleDetailsUseCase

    private(set) var vehicleDetails: VehicleDetailsDTO?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        getVehicleDetailsUseCase: GetVehicleDetailsUseCase
    ) {
        self.getVehicleDetailsUseCase = getVehicleDetailsUseCase
    }

    func loadVehicleDetails(vehicleId: UUID) async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            vehicleDetails = try await getVehicleDetailsUseCase.execute(
                vehicleId: vehicleId
            )
        } catch TerminalError.vehicleNotFound {
            vehicleDetails = nil
            errorMessage = "Vehicle not found."
        } catch TerminalError.companyNotFound {
            vehicleDetails = nil
            errorMessage = "Company not found."
        } catch {
            vehicleDetails = nil
            errorMessage = "Unable to load vehicle details."
        }
    }
}

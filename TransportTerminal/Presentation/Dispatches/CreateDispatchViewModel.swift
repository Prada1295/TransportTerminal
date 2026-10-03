//
//  CreateDispatchViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 20/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class CreateDispatchViewModel {

    private let getVehiclesInsideTerminalUseCase:
        GetVehiclesInsideTerminalUseCase
    private let getActiveRoutesUseCase: GetActiveRoutesUseCase
    private let getAvailableBaysUseCase: GetAvailableBaysUseCase
    private let createDispatchUseCase: CreateDispatchUseCase

    private(set) var vehicles: [Vehicle] = []
    private(set) var routes: [Route] = []
    private(set) var bays: [Bay] = []

    var selectedVehicleId: UUID?
    var selectedRouteId: UUID?
    var selectedBayId: UUID?

    var scheduledDeparture: Date = Date()

    private(set) var isLoading = false
    private(set) var isCreating = false
    private(set) var errorMessage: String?

    var canCreateDispatch: Bool {
        selectedVehicleId != nil &&
        selectedRouteId != nil &&
        selectedBayId != nil &&
        !isCreating
    }

    init(
        getVehiclesInsideTerminalUseCase:
            GetVehiclesInsideTerminalUseCase,
        getActiveRoutesUseCase: GetActiveRoutesUseCase,
        getAvailableBaysUseCase: GetAvailableBaysUseCase,
        createDispatchUseCase: CreateDispatchUseCase
    ) {
        self.getVehiclesInsideTerminalUseCase =
            getVehiclesInsideTerminalUseCase
        self.getActiveRoutesUseCase = getActiveRoutesUseCase
        self.getAvailableBaysUseCase = getAvailableBaysUseCase
        self.createDispatchUseCase = createDispatchUseCase
    }

    func loadOptions() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            async let loadedVehicles =
                getVehiclesInsideTerminalUseCase.execute()
            async let loadedRoutes = getActiveRoutesUseCase.execute()
            async let loadedBays = getAvailableBaysUseCase.execute()

            vehicles = try await loadedVehicles
            routes = try await loadedRoutes
            bays = try await loadedBays

        } catch {
            vehicles = []
            routes = []
            bays = []

            errorMessage = "Unable to load dispatch options."
        }
    }

    func createDispatch() async -> CreateDispatchResult? {
        guard let selectedVehicleId,
              let selectedRouteId,
              let selectedBayId else {
            errorMessage = "Please complete all required fields."
            return nil
        }

        isCreating = true
        errorMessage = nil

        defer {
            isCreating = false
        }

        do {
            return try await createDispatchUseCase.execute(
                vehicleId: selectedVehicleId,
                routeId: selectedRouteId,
                bayId: selectedBayId,
                scheduledDeparture: scheduledDeparture
            )

        } catch let error as TerminalError {
            errorMessage = message(for: error)
            return nil

        } catch {
            errorMessage = "Unable to create dispatch."
            return nil
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

private extension CreateDispatchViewModel {

    func message(for error: TerminalError) -> String {
        switch error {
        case .vehicleNotFound:
            return "The selected vehicle could not be found."

        case .vehicleInMaintenance:
            return "The selected vehicle is currently in maintenance."

        case .vehicleNotInsideTerminal:
            return "The selected vehicle is not inside the terminal."

        case .routeNotFound:
            return "The selected route could not be found."

        case .routeInactive:
            return "The selected route is inactive."

        case .bayNotFound:
            return "The selected bay could not be found."

        case .bayInactive:
            return "The selected bay is inactive."

        case .vehicleAlreadyHasActiveDispatch:
            return "This vehicle already has an active dispatch."

        case .bayAlreadyHasActiveDispatch:
            return "This bay already has an active dispatch."

        case .companyNotFound,
             .companyInactive,
             .vehicleAlreadyInside,
             .dispatchNotFound,
             .dispatchAlreadyCancelled,
             .dispatchAlreadyDeparted:
            return "Unable to create dispatch."
        }
    }
}

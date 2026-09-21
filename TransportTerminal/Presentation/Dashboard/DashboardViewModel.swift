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

    private let getVehiclesInsideTerminalUseCase:
        GetVehiclesInsideTerminalUseCase

    private let getVehiclesUseCase:
        GetVehiclesUseCase

    private let getActiveDispatchesUseCase:
        GetActiveDispatchesUseCase

    private let bayRepository:
        BayRepository

    private(set) var vehiclesAvailableForEntry: [Vehicle] = []
    private(set) var vehiclesInsideTerminal: [Vehicle] = []

    private(set) var activeDispatches: [Dispatch] = []
    private(set) var occupiedBayCount = 0

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        getVehiclesInsideTerminalUseCase:
            GetVehiclesInsideTerminalUseCase,
        getVehiclesUseCase:
            GetVehiclesUseCase,
        getActiveDispatchesUseCase:
            GetActiveDispatchesUseCase,
        bayRepository:
            BayRepository
    ) {
        self.getVehiclesInsideTerminalUseCase =
            getVehiclesInsideTerminalUseCase

        self.getVehiclesUseCase =
            getVehiclesUseCase

        self.getActiveDispatchesUseCase =
            getActiveDispatchesUseCase

        self.bayRepository =
            bayRepository
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

            async let dispatches =
                getActiveDispatchesUseCase.execute()

            async let bays =
                bayRepository.getAll()

            let (
                vehiclesInside,
                vehicles,
                activeDispatches,
                allBays
            ) = try await (
                insideVehicles,
                allVehicles,
                dispatches,
                bays
            )

            vehiclesInsideTerminal =
                vehiclesInside

            vehiclesAvailableForEntry =
                vehicles.filter {
                    $0.status == .outsideTerminal
                }

            self.activeDispatches =
                activeDispatches

            let occupiedBayIds =
                Set(
                    activeDispatches.map(\.bayId)
                )

            occupiedBayCount =
                allBays.filter {
                    occupiedBayIds.contains($0.id)
                }.count

        } catch {

            vehiclesInsideTerminal = []
            vehiclesAvailableForEntry = []
            activeDispatches = []
            occupiedBayCount = 0

            errorMessage =
                "Unable to load dashboard information."
        }
    }
}

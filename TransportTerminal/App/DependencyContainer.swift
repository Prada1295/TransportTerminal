//
//  DependencyContainer.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation

public final class DependencyContainer {
    public let vehicleRepository: VehicleRepository
    public let companyRepository: CompanyRepository
    public let routeRepository: RouteRepository
    public let bayRepository: BayRepository
    public let dispatchRepository: DispatchRepository
    public let movementRepository: VehicleMovementRepository
    
    public init() {
        self.vehicleRepository = InMemoryVehicleRepository(
            vehicles: InMemorySeedData.vehicles
        )
        self.companyRepository = InMemoryCompanyRepository(
            companies: InMemorySeedData.companies
        )
        self.routeRepository = InMemoryRouteRepository(
            routes: InMemorySeedData.routes
        )
        self.bayRepository = InMemoryBayRepository(
            bays: InMemorySeedData.bays
        )
        self.dispatchRepository = InMemoryDispatchRepository(
            dispatches: InMemorySeedData.dispatches
        )
        self.movementRepository = InMemoryVehicleMovementRepository(
            movements: InMemorySeedData.movements
        )
    }
    
    public func makeRegisterVehicleEntryUseCase() -> RegisterVehicleEntryUseCase {
        RegisterVehicleEntry(
            vehicleRepository: vehicleRepository,
            companyRepository: companyRepository,
            movementRepository: movementRepository
        )
    }
    
    public func makeRegisterVehicleExitUseCase() -> RegisterVehicleExitUseCase {
        RegisterVehicleExit(
            vehicleRepository: vehicleRepository,
            movementRepository: movementRepository
        )
    }
    
    public func makeGetVehiclesInsideTerminalUseCase() -> GetVehiclesInsideTerminalUseCase {
        GetVehiclesInsideTerminal(vehicleRepository: vehicleRepository)
    }
    
    public func makeGetVehiclesUseCase() -> GetVehiclesUseCase {
        GetVehicles(
            vehicleRepository: vehicleRepository
        )
    }
    
    public func makeCreateDispatchUseCase() -> CreateDispatchUseCase {
        CreateDispatch(
            vehicleRepository: vehicleRepository,
            routeRepository: routeRepository,
            bayRepository: bayRepository,
            dispatchRepository: dispatchRepository
        )
    }
    
    public func makeCancelDispatchUseCase() -> CancelDispatchUseCase {
        CancelDispatch(dispatchRepository: dispatchRepository)
    }
    
    public func makeGetVehicleDetailsUseCase() -> GetVehicleDetailsUseCase {
        GetVehicleDetails(
            vehicleRepository: vehicleRepository,
            companyRepository: companyRepository
        )
    }
    
    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getVehiclesInsideTerminalUseCase: makeGetVehiclesInsideTerminalUseCase()
        )
    }
    
    @MainActor
    func makeVehicleDetailViewModel() -> VehicleDetailViewModel {
        VehicleDetailViewModel(
            getVehicleDetailsUseCase: makeGetVehicleDetailsUseCase()
        )
    }
    
    @MainActor
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            getVehiclesInsideTerminalUseCase:
                makeGetVehiclesInsideTerminalUseCase(),
            getVehiclesUseCase:
                makeGetVehiclesUseCase()
        )
    }
    
    @MainActor
    func makeRegisterVehicleEntryViewModel() -> RegisterVehicleEntryViewModel {
        RegisterVehicleEntryViewModel(
            registerVehicleEntryUseCase:
                makeRegisterVehicleEntryUseCase()
        )
    }

}



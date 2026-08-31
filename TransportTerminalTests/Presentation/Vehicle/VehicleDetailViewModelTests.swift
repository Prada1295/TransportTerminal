//
//  VehicleDetailViewModelTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct VehicleDetailViewModelTests {

    @Test
    func loadVehicleDetailsWhenUseCaseSucceedsSetsVehicleDetails() async {

        let company = makeCompany()
        let vehicle = makeVehicle(companyId: company.id)

        let expectedDetails = VehicleDetailsDTO(
            vehicle: vehicle,
            company: company
        )

        let sut = makeSUT(
            result: .success(expectedDetails)
        )

        await sut.loadVehicleDetails(vehicleId: vehicle.id)

        #expect(sut.vehicleDetails == expectedDetails)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test
    func loadVehicleDetailsWhenVehicleIsNotFoundSetsErrorMessage() async {

        let sut = makeSUT(
            result: .failure(TerminalError.vehicleNotFound)
        )

        await sut.loadVehicleDetails(vehicleId: UUID())

        #expect(sut.vehicleDetails == nil)
        #expect(sut.errorMessage == "Vehicle not found.")
        #expect(sut.isLoading == false)
    }

    @Test
    func loadVehicleDetailsWhenCompanyIsNotFoundSetsErrorMessage() async {

        let sut = makeSUT(
            result: .failure(TerminalError.companyNotFound)
        )

        await sut.loadVehicleDetails(vehicleId: UUID())

        #expect(sut.vehicleDetails == nil)
        #expect(sut.errorMessage == "Company not found.")
        #expect(sut.isLoading == false)
    }

    @Test
    func loadVehicleDetailsWhenUseCaseFailsWithUnknownErrorSetsGenericErrorMessage() async {

        let sut = makeSUT(
            result: .failure(TestError.generic)
        )

        await sut.loadVehicleDetails(vehicleId: UUID())

        #expect(sut.vehicleDetails == nil)
        #expect(sut.errorMessage == "Unable to load vehicle details.")
        #expect(sut.isLoading == false)
    }
}

private extension VehicleDetailViewModelTests {

    func makeSUT(
        result: Result<VehicleDetailsDTO, Error>
    ) -> VehicleDetailViewModel {

        VehicleDetailViewModel(
            getVehicleDetailsUseCase: FakeGetVehicleDetailsUseCase(
                result: result
            )
        )
    }

    func makeVehicle(
        id: UUID = UUID(),
        plate: String = "ABC123",
        companyId: UUID = UUID(),
        type: VehicleType = .bus,
        capacity: Int = 40,
        status: VehicleStatus = .insideTerminal
    ) -> Vehicle {

        Vehicle(
            id: id,
            plate: plate,
            companyId: companyId,
            type: type,
            capacity: capacity,
            status: status
        )
    }

    func makeCompany(
        id: UUID = UUID(),
        name: String = "Transportes Nacionales",
        nit: String = "900123456",
        isActive: Bool = true
    ) -> Company {

        Company(
            id: id,
            name: name,
            nit: nit,
            isActive: isActive
        )
    }
}

private final class FakeGetVehicleDetailsUseCase: GetVehicleDetailsUseCase {

    private let result: Result<VehicleDetailsDTO, Error>

    init(result: Result<VehicleDetailsDTO, Error>) {
        self.result = result
    }

    func execute(
        vehicleId: UUID
    ) async throws -> VehicleDetailsDTO {

        try result.get()
    }
}

private enum TestError: Error {
    case generic
}

//
//  GetVehicleDetailsUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct GetVehicleDetailsUseCaseTests {

    @Test
    func executeWhenVehicleAndCompanyExistReturnsVehicleDetails() async throws {

        let company = makeCompany()
        let vehicle = makeVehicle(companyId: company.id)

        let sut = makeSUT(
            vehicles: [vehicle],
            companies: [company]
        )

        let result = try await sut.execute(
            vehicleId: vehicle.id
        )

        #expect(result.vehicle == vehicle)
        #expect(result.company == company)
    }

    @Test
    func executeWhenVehicleDoesNotExistThrowsVehicleNotFound() async {

        let sut = makeSUT()

        await #expect(
            throws: TerminalError.vehicleNotFound
        ) {
            try await sut.execute(vehicleId: UUID())
        }
    }

    @Test
    func executeWhenCompanyDoesNotExistThrowsCompanyNotFound() async {

        let vehicle = makeVehicle()
        let company = makeCompany()

        let sut = makeSUT(
            vehicles: [vehicle],
            companies: [company]
        )

        await #expect(
            throws: TerminalError.companyNotFound
        ) {
            try await sut.execute(
                vehicleId: vehicle.id
            )
        }
    }
}

private extension GetVehicleDetailsUseCaseTests {

    func makeSUT(
        vehicles: [Vehicle] = [],
        companies: [Company] = []
    ) -> GetVehicleDetailsUseCase {

        GetVehicleDetails(
            vehicleRepository: InMemoryVehicleRepository(
                vehicles: vehicles
            ),
            companyRepository: InMemoryCompanyRepository(
                companies: companies
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

//
//  GetVehicleDetailsUseCase.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct GetAvailableBaysUseCaseTests {

    @Test
    func executeWhenRepositoriesAreEmptyReturnsEmptyList() async throws {
        let sut = makeSUT()

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test
    func executeWhenNoBaysAreActiveReturnsEmptyList() async throws {
        let bays = [
            makeBay(active: false),
            makeBay(active: false)
        ]

        let sut = makeSUT(bays: bays)

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test
    func executeWhenAllBaysAreActiveReturnsAllBays() async throws {
        let bayOne = makeBay(code: "Bay 01")
        let bayTwo = makeBay(code: "Bay 02")
        let bayThree = makeBay(code: "Bay 03")

        let sut = makeSUT(
            bays: [
                bayOne,
                bayTwo,
                bayThree
            ]
        )

        let result = try await sut.execute()

        #expect(result.count == 3)
        #expect(result[0].id == bayOne.id)
        #expect(result[1].id == bayTwo.id)
        #expect(result[2].id == bayThree.id)
    }

    @Test
    func executeExcludesInactiveBays() async throws {
        let activeBay = makeBay(
            code: "Bay 01",
            active: true
        )

        let inactiveBay = makeBay(
            code: "Bay 02",
            active: false
        )

        let sut = makeSUT(
            bays: [
                activeBay,
                inactiveBay
            ]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == activeBay.id)
    }

    @Test
    func executeExcludesBayOccupiedByScheduledDispatch() async throws {
        let availableBay = makeBay(code: "Bay 01")
        let occupiedBay = makeBay(code: "Bay 02")

        let dispatch = makeDispatch(
            bayId: occupiedBay.id,
            status: .scheduled
        )

        let sut = makeSUT(
            bays: [
                availableBay,
                occupiedBay
            ],
            dispatches: [dispatch]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == availableBay.id)
    }

    @Test
    func executeExcludesBayOccupiedByBoardingDispatch() async throws {
        let availableBay = makeBay(code: "Bay 01")
        let occupiedBay = makeBay(code: "Bay 02")

        let dispatch = makeDispatch(
            bayId: occupiedBay.id,
            status: .boarding
        )

        let sut = makeSUT(
            bays: [
                availableBay,
                occupiedBay
            ],
            dispatches: [dispatch]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == availableBay.id)
    }

    @Test
    func executeExcludesBayOccupiedByDelayedDispatch() async throws {
        let availableBay = makeBay(code: "Bay 01")
        let occupiedBay = makeBay(code: "Bay 02")

        let dispatch = makeDispatch(
            bayId: occupiedBay.id,
            status: .delayed
        )

        let sut = makeSUT(
            bays: [
                availableBay,
                occupiedBay
            ],
            dispatches: [dispatch]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == availableBay.id)
    }

    @Test
    func executeIncludesBayWithCancelledDispatch() async throws {
        let bay = makeBay(code: "Bay 01")

        let dispatch = makeDispatch(
            bayId: bay.id,
            status: .cancelled
        )

        let sut = makeSUT(
            bays: [bay],
            dispatches: [dispatch]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == bay.id)
    }

    @Test
    func executeIncludesBayWithDepartedDispatch() async throws {
        let bay = makeBay(code: "Bay 01")

        let dispatch = makeDispatch(
            bayId: bay.id,
            status: .departed
        )

        let sut = makeSUT(
            bays: [bay],
            dispatches: [dispatch]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == bay.id)
    }

    @Test
    func executeReturnsOnlyAvailableBaysWhenThereAreMultipleDispatches() async throws {
        let availableBay = makeBay(code: "Bay 01")
        let scheduledBay = makeBay(code: "Bay 02")
        let boardingBay = makeBay(code: "Bay 03")
        let delayedBay = makeBay(code: "Bay 04")

        let scheduledDispatch = makeDispatch(
            bayId: scheduledBay.id,
            status: .scheduled
        )

        let boardingDispatch = makeDispatch(
            bayId: boardingBay.id,
            status: .boarding
        )

        let delayedDispatch = makeDispatch(
            bayId: delayedBay.id,
            status: .delayed
        )

        let sut = makeSUT(
            bays: [
                availableBay,
                scheduledBay,
                boardingBay,
                delayedBay
            ],
            dispatches: [
                scheduledDispatch,
                boardingDispatch,
                delayedDispatch
            ]
        )

        let result = try await sut.execute()

        #expect(result.count == 1)
        #expect(result.first?.id == availableBay.id)
    }
}


// MARK: - Helpers

private extension GetAvailableBaysUseCaseTests {

    func makeSUT(
        bays: [Bay] = [],
        dispatches: [Dispatch] = []
    ) -> GetAvailableBaysUseCase {

        GetAvailableBays(
            bayRepository: FakeBayRepository(
                bays: bays
            ),
            dispatchRepository: FakeDispatchRepository(
                dispatches: dispatches
            )
        )
    }

    func makeBay(
        id: UUID = UUID(),
        code: String = "Bay 01",
        active: Bool = true
    ) -> Bay {

        Bay(
            id: id,
            code: code,
            active: active
        )
    }

    func makeDispatch(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID,
        scheduledDeparture: Date = Date(),
        actualDeparture: Date? = nil,
        status: DispatchStatus
    ) -> Dispatch {

        Dispatch(
            id: id,
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            status: status
        )
    }
}


// MARK: - Fakes

private final class FakeBayRepository: BayRepository {

    private var bays: [Bay]

    init(bays: [Bay]) {
        self.bays = bays
    }

    func getById(_ id: UUID) async throws -> Bay? {
        bays.first { $0.id == id }
    }

    func getAll() async throws -> [Bay] {
        bays
    }

    func save(_ bay: Bay) async throws {
        bays.append(bay)
    }
}


private final class FakeDispatchRepository: DispatchRepository {

    private var dispatches: [Dispatch]

    init(dispatches: [Dispatch]) {
        self.dispatches = dispatches
    }

    func save(_ dispatch: Dispatch) async throws {
        dispatches.append(dispatch)
    }

    func getById(_ id: UUID) async throws -> Dispatch? {
        dispatches.first { $0.id == id }
    }

    func getActiveDispatches() async throws -> [Dispatch] {
        dispatches.filter { dispatch in
            dispatch.status != .cancelled &&
            dispatch.status != .departed
        }
    }

    func update(_ dispatch: Dispatch) async throws {
        guard let index = dispatches.firstIndex(
            where: { $0.id == dispatch.id }
        ) else {
            return
        }

        dispatches[index] = dispatch
    }
}

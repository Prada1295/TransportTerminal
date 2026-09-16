//
//  GetActiveDispatchesUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 15/09/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct GetActiveDispatchesUseCaseTests {

    @Test
    func executeWhenRepositoryIsEmptyReturnsEmptyList() async throws {

        let sut = makeSUT()

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test
    func executeWhenThereAreNoActiveDispatchesReturnsEmptyList() async throws {

        let dispatches = [
            makeDispatch(status: .cancelled),
            makeDispatch(status: .departed)
        ]

        let sut = makeSUT(
            dispatches: dispatches
        )

        let result = try await sut.execute()

        #expect(result.isEmpty)
    }

    @Test
    func executeReturnsOnlyActiveDispatches() async throws {

        let scheduledDispatch = makeDispatch(
            status: .scheduled
        )

        let boardingDispatch = makeDispatch(
            status: .boarding
        )

        let delayedDispatch = makeDispatch(
            status: .delayed
        )

        let cancelledDispatch = makeDispatch(
            status: .cancelled
        )

        let departedDispatch = makeDispatch(
            status: .departed
        )

        let sut = makeSUT(
            dispatches: [
                scheduledDispatch,
                boardingDispatch,
                delayedDispatch,
                cancelledDispatch,
                departedDispatch
            ]
        )

        let result = try await sut.execute()

        #expect(
            result == [
                scheduledDispatch,
                boardingDispatch,
                delayedDispatch
            ]
        )
    }
}


// MARK: - Helpers

private extension GetActiveDispatchesUseCaseTests {

    func makeSUT(
        dispatches: [Dispatch] = []
    ) -> GetActiveDispatchesUseCase {

        GetActiveDispatches(
            dispatchRepository: FakeDispatchRepository(
                dispatches: dispatches
            )
        )
    }

    func makeDispatch(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID = UUID(),
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


// MARK: - Fake

private final class FakeDispatchRepository: DispatchRepository {

    private let dispatches: [Dispatch]

    init(dispatches: [Dispatch]) {
        self.dispatches = dispatches
    }

    func save(_ dispatch: Dispatch) async throws {
        // Not needed for these tests.
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
        // Not needed for these tests.
    }
}

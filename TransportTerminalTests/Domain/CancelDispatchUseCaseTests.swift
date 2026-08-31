//
//  CancelDispatchUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 25/08/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct CancelDispatchUseCaseTests {
    @Test func executeWhenDispatchDoesNotExistThrowsDispatchNotFound() async throws {
        let sut = makeSUT()

        await expectTerminalError(.dispatchNotFound) {
            _ = try await sut.execute(dispatchId: UUID())
        }
    }

    @Test func executeWhenDispatchIsAlreadyCancelledThrowsDispatchAlreadyCancelled() async throws {
        let dispatch = makeDispatch(status: .cancelled)
        let sut = makeSUT(dispatches: [dispatch])

        await expectTerminalError(.dispatchAlreadyCancelled) {
            _ = try await sut.execute(dispatchId: dispatch.id)
        }
    }

    @Test func executeWhenDispatchIsAlreadyDepartedThrowsDispatchAlreadyDeparted() async throws {
        let dispatch = makeDispatch(status: .departed)
        let sut = makeSUT(dispatches: [dispatch])

        await expectTerminalError(.dispatchAlreadyDeparted) {
            _ = try await sut.execute(dispatchId: dispatch.id)
        }
    }

    @Test func executeWhenDispatchIsScheduledCancelsDispatch() async throws {
        let dispatch = makeDispatch(status: .scheduled)
        let repository = FakeCancelDispatchRepository(dispatches: [dispatch])
        let sut = makeSUT(dispatchRepository: repository)

        let result = try await sut.execute(dispatchId: dispatch.id)

        #expect(result.dispatchId == dispatch.id)
        #expect(result.vehicleId == dispatch.vehicleId)
        #expect(result.routeId == dispatch.routeId)
        #expect(result.bayId == dispatch.bayId)
        #expect(result.status == .cancelled)
        #expect(repository.updatedDispatches.count == 1)
        #expect(repository.updatedDispatches.first?.id == dispatch.id)
        #expect(repository.updatedDispatches.first?.status == .cancelled)
    }

    @Test func executeWhenDispatchIsBoardingCancelsDispatch() async throws {
        let dispatch = makeDispatch(status: .boarding)
        let repository = FakeCancelDispatchRepository(dispatches: [dispatch])
        let sut = makeSUT(dispatchRepository: repository)

        let result = try await sut.execute(dispatchId: dispatch.id)

        #expect(result.status == .cancelled)
        #expect(repository.updatedDispatches.first?.status == .cancelled)
    }

    @Test func executeWhenDispatchIsDelayedCancelsDispatch() async throws {
        let dispatch = makeDispatch(status: .delayed)
        let repository = FakeCancelDispatchRepository(dispatches: [dispatch])
        let sut = makeSUT(dispatchRepository: repository)

        let result = try await sut.execute(dispatchId: dispatch.id)

        #expect(result.status == .cancelled)
        #expect(repository.updatedDispatches.first?.status == .cancelled)
    }
}

private extension CancelDispatchUseCaseTests {
    func makeSUT(dispatches: [Dispatch] = []) -> CancelDispatchUseCase {
        makeSUT(
            dispatchRepository: FakeCancelDispatchRepository(dispatches: dispatches)
        )
    }

    func makeSUT(dispatchRepository: DispatchRepository) -> CancelDispatchUseCase {
        CancelDispatch(dispatchRepository: dispatchRepository)
    }

    func makeDispatch(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID = UUID(),
        scheduledDeparture: Date = Date(),
        status: DispatchStatus = .scheduled
    ) -> Dispatch {
        Dispatch(
            id: id,
            vehicleId: vehicleId,
            routeId: routeId,
            bayId: bayId,
            scheduledDeparture: scheduledDeparture,
            status: status
        )
    }

    func expectTerminalError(
        _ expectedError: TerminalError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            Issue.record("Expected error: \(expectedError)")
        } catch let error as TerminalError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

private final class FakeCancelDispatchRepository: DispatchRepository {
    private var dispatches: [Dispatch]
    private(set) var updatedDispatches: [Dispatch] = []

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
            dispatch.status != .cancelled && dispatch.status != .departed
        }
    }

    func update(_ dispatch: Dispatch) async throws {
        updatedDispatches.append(dispatch)

        guard let index = dispatches.firstIndex(where: { $0.id == dispatch.id }) else {
            return
        }

        dispatches[index] = dispatch
    }
}

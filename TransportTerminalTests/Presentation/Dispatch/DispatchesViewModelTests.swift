//
//  DispatchesViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 15/09/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct DispatchesViewModelTests {

    // MARK: - Load

    @Test
    func loadDispatchesWhenUseCaseSucceedsLoadsDispatches() async {

        let dispatch = makeDispatchDetails()

        let getActiveDispatches = FakeGetActiveDispatchDetailsUseCase(
            result: [dispatch]
        )

        let sut = makeSUT(
            getActiveDispatchDetailsUseCase: getActiveDispatches
        )

        await sut.loadDispatches()

        #expect(sut.dispatches == [dispatch])
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
        #expect(getActiveDispatches.executeCallCount == 1)
    }

    @Test
    func loadDispatchesWhenUseCaseFailsClearsDispatchesAndSetsError() async {

        let getActiveDispatches = FakeGetActiveDispatchDetailsUseCase(
            error: TerminalError.dispatchNotFound
        )

        let sut = makeSUT(
            getActiveDispatchDetailsUseCase: getActiveDispatches
        )

        await sut.loadDispatches()

        #expect(sut.dispatches.isEmpty)
        #expect(sut.isLoading == false)
        #expect(
            sut.errorMessage == "Unable to load dispatch information."
        )
        #expect(getActiveDispatches.executeCallCount == 1)
    }

    // MARK: - Cancel

    @Test
    func cancelDispatchWhenUseCaseSucceedsExecutesAndReloadsDispatches() async {

        let dispatch = makeDispatchDetails()

        let getActiveDispatches = FakeGetActiveDispatchDetailsUseCase(
            result: [dispatch]
        )

        let cancelDispatch = FakeCancelDispatchUseCase()

        let sut = makeSUT(
            getActiveDispatchDetailsUseCase: getActiveDispatches,
            cancelDispatchUseCase: cancelDispatch
        )

        await sut.cancelDispatch(dispatch)

        #expect(
            cancelDispatch.executedDispatchIds == [dispatch.id]
        )

        #expect(
            getActiveDispatches.executeCallCount == 1
        )

        #expect(
            sut.dispatches == [dispatch]
        )

        #expect(sut.errorMessage == nil)
    }

    @Test
    func cancelDispatchWhenUseCaseFailsSetsError() async {

        let dispatch = makeDispatchDetails()

        let getActiveDispatches = FakeGetActiveDispatchDetailsUseCase(
            result: [dispatch]
        )

        let cancelDispatch = FakeCancelDispatchUseCase(
            error: TerminalError.dispatchAlreadyCancelled
        )

        let sut = makeSUT(
            getActiveDispatchDetailsUseCase: getActiveDispatches,
            cancelDispatchUseCase: cancelDispatch
        )

        await sut.cancelDispatch(dispatch)

        #expect(
            cancelDispatch.executedDispatchIds == [dispatch.id]
        )

        #expect(
            sut.errorMessage == "Unable to cancel dispatch."
        )

        #expect(
            getActiveDispatches.executeCallCount == 0
        )
    }

    // MARK: - Execute

    @Test
    func executeDispatchWhenUseCaseSucceedsExecutesAndReloadsDispatches() async {

        let dispatch = makeDispatchDetails()

        let getActiveDispatches = FakeGetActiveDispatchDetailsUseCase(
            result: [dispatch]
        )

        let executeDispatch = FakeExecuteDispatchUseCase()

        let sut = makeSUT(
            getActiveDispatchDetailsUseCase: getActiveDispatches,
            executeDispatchUseCase: executeDispatch
        )

        await sut.executeDispatch(dispatch)

        #expect(
            executeDispatch.executedDispatchIds == [dispatch.id]
        )

        #expect(
            getActiveDispatches.executeCallCount == 1
        )

        #expect(
            sut.dispatches == [dispatch]
        )

        #expect(sut.errorMessage == nil)
    }

    @Test
    func executeDispatchWhenUseCaseFailsSetsError() async {

        let dispatch = makeDispatchDetails()

        let getActiveDispatches = FakeGetActiveDispatchDetailsUseCase(
            result: [dispatch]
        )

        let executeDispatch = FakeExecuteDispatchUseCase(
            error: TerminalError.dispatchAlreadyDeparted
        )

        let sut = makeSUT(
            getActiveDispatchDetailsUseCase: getActiveDispatches,
            executeDispatchUseCase: executeDispatch
        )

        await sut.executeDispatch(dispatch)

        #expect(
            executeDispatch.executedDispatchIds == [dispatch.id]
        )

        #expect(
            sut.errorMessage == "Unable to execute dispatch."
        )

        #expect(
            getActiveDispatches.executeCallCount == 0
        )
    }
}


// MARK: - Helpers

private extension DispatchesViewModelTests {

    func makeSUT(
        getActiveDispatchDetailsUseCase:
            GetActiveDispatchDetailsUseCase =
                FakeGetActiveDispatchDetailsUseCase(),

        cancelDispatchUseCase: CancelDispatchUseCase =
            FakeCancelDispatchUseCase(),

        executeDispatchUseCase: ExecuteDispatchUseCase =
            FakeExecuteDispatchUseCase()
    ) -> DispatchesViewModel {

        DispatchesViewModel(
            getActiveDispatchDetailsUseCase:
                getActiveDispatchDetailsUseCase,
            cancelDispatchUseCase: cancelDispatchUseCase,
            executeDispatchUseCase: executeDispatchUseCase
        )
    }

    func makeDispatchDetails(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        vehiclePlate: String = "ABC123",
        vehicleType: VehicleType = .bus,
        routeId: UUID = UUID(),
        routeOrigin: String = "Medellin",
        routeDestination: String = "Bogota",
        bayId: UUID = UUID(),
        bayCode: String = "B01",
        scheduledDeparture: Date = Date(),
        actualDeparture: Date? = nil,
        status: DispatchStatus = .scheduled
    ) -> DispatchDetailsResult {

        DispatchDetailsResult(
            id: id,
            vehicleId: vehicleId,
            vehiclePlate: vehiclePlate,
            vehicleType: vehicleType,
            routeId: routeId,
            routeOrigin: routeOrigin,
            routeDestination: routeDestination,
            bayId: bayId,
            bayCode: bayCode,
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            status: status
        )
    }
}


// MARK: - Fake GetActiveDispatchDetails

private final class FakeGetActiveDispatchDetailsUseCase:
    GetActiveDispatchDetailsUseCase {

    private let result: [DispatchDetailsResult]
    private let error: Error?

    private(set) var executeCallCount = 0

    init(
        result: [DispatchDetailsResult] = [],
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute() async throws -> [DispatchDetailsResult] {

        executeCallCount += 1

        if let error {
            throw error
        }

        return result
    }
}


// MARK: - Fake CancelDispatch

private final class FakeCancelDispatchUseCase:
    CancelDispatchUseCase {

    private let error: Error?

    private(set) var executedDispatchIds: [UUID] = []

    init(
        error: Error? = nil
    ) {
        self.error = error
    }

    func execute(
        dispatchId: UUID
    ) async throws -> CancelDispatchResult {

        executedDispatchIds.append(dispatchId)

        if let error {
            throw error
        }

        return CancelDispatchResult(
            dispatchId: dispatchId,
            vehicleId: UUID(),
            routeId: UUID(),
            bayId: UUID(),
            status: .cancelled
        )
    }
}


// MARK: - Fake ExecuteDispatch

private final class FakeExecuteDispatchUseCase:
    ExecuteDispatchUseCase {

    private let error: Error?

    private(set) var executedDispatchIds: [UUID] = []

    init(
        error: Error? = nil
    ) {
        self.error = error
    }

    func execute(
        dispatchId: UUID
    ) async throws -> ExecuteDispatchResult {

        executedDispatchIds.append(dispatchId)

        if let error {
            throw error
        }

        let scheduledDeparture = Date()
        let actualDeparture = Date()

        return ExecuteDispatchResult(
            dispatchId: dispatchId,
            vehicleId: UUID(),
            routeId: UUID(),
            bayId: UUID(),
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            status: .departed
        )
    }
}

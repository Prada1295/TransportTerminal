//
//  DispatchDetailViewModelTests.swift
//  TransportTerminalTests
//
//  Created by Codex on 3/10/26.
//

import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct DispatchDetailViewModelTests {

    @Test
    func executeDispatchWhenUseCaseSucceedsReturnsResult() async {
        let dispatch = makeDispatchDetails()
        let expectedResult = ExecuteDispatchResult(
            dispatchId: dispatch.id,
            vehicleId: dispatch.vehicleId,
            routeId: dispatch.routeId,
            bayId: dispatch.bayId,
            scheduledDeparture: dispatch.scheduledDeparture,
            actualDeparture: Date(),
            status: .departed
        )
        let executeUseCase = FakeDispatchDetailExecuteUseCase(
            result: expectedResult
        )
        let sut = makeSUT(
            dispatch: dispatch,
            executeDispatchUseCase: executeUseCase
        )

        let result = await sut.executeDispatch()

        #expect(result == expectedResult)
        #expect(executeUseCase.executedDispatchIds == [dispatch.id])
        #expect(sut.errorMessage == nil)
        #expect(sut.isExecuting == false)
    }

    @Test
    func executeDispatchWhenUseCaseFailsSetsSpecificError() async {
        let executeUseCase = FakeDispatchDetailExecuteUseCase(
            error: TerminalError.vehicleNotInsideTerminal
        )
        let sut = makeSUT(
            executeDispatchUseCase: executeUseCase
        )

        let result = await sut.executeDispatch()

        #expect(result == nil)
        #expect(sut.errorMessage == "Vehicle is not inside the terminal.")
        #expect(sut.isExecuting == false)
    }

    @Test
    func cancelDispatchWhenUseCaseSucceedsReturnsResult() async {
        let dispatch = makeDispatchDetails()
        let expectedResult = CancelDispatchResult(
            dispatchId: dispatch.id,
            vehicleId: dispatch.vehicleId,
            routeId: dispatch.routeId,
            bayId: dispatch.bayId,
            status: .cancelled
        )
        let cancelUseCase = FakeDispatchDetailCancelUseCase(
            result: expectedResult
        )
        let sut = makeSUT(
            dispatch: dispatch,
            cancelDispatchUseCase: cancelUseCase
        )

        let result = await sut.cancelDispatch()

        #expect(result == expectedResult)
        #expect(cancelUseCase.executedDispatchIds == [dispatch.id])
        #expect(sut.errorMessage == nil)
        #expect(sut.isCancelling == false)
    }

    @Test
    func cancelDispatchWhenUseCaseFailsSetsSpecificError() async {
        let cancelUseCase = FakeDispatchDetailCancelUseCase(
            error: TerminalError.dispatchAlreadyDeparted
        )
        let sut = makeSUT(
            cancelDispatchUseCase: cancelUseCase
        )

        let result = await sut.cancelDispatch()

        #expect(result == nil)
        #expect(sut.errorMessage == "Dispatch has already departed.")
        #expect(sut.isCancelling == false)
    }
}

private extension DispatchDetailViewModelTests {

    func makeSUT(
        dispatch: DispatchDetailsResult? = nil,
        cancelDispatchUseCase: CancelDispatchUseCase =
            FakeDispatchDetailCancelUseCase(),
        executeDispatchUseCase: ExecuteDispatchUseCase =
            FakeDispatchDetailExecuteUseCase()
    ) -> DispatchDetailViewModel {

        DispatchDetailViewModel(
            dispatch: dispatch ?? makeDispatchDetails(),
            cancelDispatchUseCase: cancelDispatchUseCase,
            executeDispatchUseCase: executeDispatchUseCase
        )
    }

    func makeDispatchDetails(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID = UUID(),
        scheduledDeparture: Date = Date(),
        actualDeparture: Date? = nil,
        status: DispatchStatus = .scheduled
    ) -> DispatchDetailsResult {

        DispatchDetailsResult(
            id: id,
            vehicleId: vehicleId,
            vehiclePlate: "ABC123",
            vehicleType: .bus,
            routeId: routeId,
            routeOrigin: "Medellin",
            routeDestination: "Bogota",
            bayId: bayId,
            bayCode: "B01",
            scheduledDeparture: scheduledDeparture,
            actualDeparture: actualDeparture,
            status: status
        )
    }
}

private final class FakeDispatchDetailCancelUseCase:
    CancelDispatchUseCase {

    private let result: CancelDispatchResult?
    private let error: Error?

    private(set) var executedDispatchIds: [UUID] = []

    init(
        result: CancelDispatchResult? = nil,
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute(dispatchId: UUID) async throws -> CancelDispatchResult {
        executedDispatchIds.append(dispatchId)

        if let error {
            throw error
        }

        return result ?? CancelDispatchResult(
            dispatchId: dispatchId,
            vehicleId: UUID(),
            routeId: UUID(),
            bayId: UUID(),
            status: .cancelled
        )
    }
}

private final class FakeDispatchDetailExecuteUseCase:
    ExecuteDispatchUseCase {

    private let result: ExecuteDispatchResult?
    private let error: Error?

    private(set) var executedDispatchIds: [UUID] = []

    init(
        result: ExecuteDispatchResult? = nil,
        error: Error? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute(dispatchId: UUID) async throws -> ExecuteDispatchResult {
        executedDispatchIds.append(dispatchId)

        if let error {
            throw error
        }

        let departure = Date()

        return result ?? ExecuteDispatchResult(
            dispatchId: dispatchId,
            vehicleId: UUID(),
            routeId: UUID(),
            bayId: UUID(),
            scheduledDeparture: departure,
            actualDeparture: departure,
            status: .departed
        )
    }
}

//
//  ExecuteDispatchUseCaseTests.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 14/09/26.
//
import Foundation
import Testing
@testable import TransportTerminal

@MainActor
struct ExecuteDispatchUseCaseTests {

    @Test
    func executeWhenDispatchDoesNotExistThrowsDispatchNotFound() async throws {
        let sut = makeSUT()

        await expectTerminalError(.dispatchNotFound) {
            _ = try await sut.execute(dispatchId: UUID())
        }
    }

    @Test
    func executeWhenDispatchIsAlreadyCancelledThrowsDispatchAlreadyCancelled() async throws {
        let dispatch = makeDispatch(status: .cancelled)
        let sut = makeSUT(dispatches: [dispatch])

        await expectTerminalError(.dispatchAlreadyCancelled) {
            _ = try await sut.execute(dispatchId: dispatch.id)
        }
    }

    @Test
    func executeWhenDispatchIsAlreadyDepartedThrowsDispatchAlreadyDeparted() async throws {
        let dispatch = makeDispatch(status: .departed)
        let sut = makeSUT(dispatches: [dispatch])

        await expectTerminalError(.dispatchAlreadyDeparted) {
            _ = try await sut.execute(dispatchId: dispatch.id)
        }
    }
    
    @Test
    func executeWhenDispatchIsScheduledExecutesDeparture() async throws {

        // Arrange
        let vehicleId = UUID()

        let dispatch = makeDispatch(
            vehicleId: vehicleId,
            status: .scheduled
        )

        let exitTimestamp = Date()

        let vehicleExit = FakeExecuteDispatchVehicleExitUseCase(
            result: makeVehicleExitResult(
                vehicleId: vehicleId,
                timestamp: exitTimestamp
            )
        )

        let dispatchRepository = makeRepositories(
            dispatches: [dispatch]
        )

        let sut = makeSUT(
            dispatchRepository: dispatchRepository,
            registerVehicleExit: vehicleExit
        )

        // Act
        let result = try await sut.execute(
            dispatchId: dispatch.id
        )

        // Assert
        #expect(
            result == ExecuteDispatchResult(
                dispatchId: dispatch.id,
                vehicleId: dispatch.vehicleId,
                routeId: dispatch.routeId,
                bayId: dispatch.bayId,
                scheduledDeparture: dispatch.scheduledDeparture,
                actualDeparture: exitTimestamp,
                status: .departed
            )
        )

        #expect(vehicleExit.executedVehicleIds == [vehicleId])

        #expect(
            dispatchRepository.updatedDispatches == [
                Dispatch(
                    id: dispatch.id,
                    vehicleId: dispatch.vehicleId,
                    routeId: dispatch.routeId,
                    bayId: dispatch.bayId,
                    scheduledDeparture: dispatch.scheduledDeparture,
                    actualDeparture: exitTimestamp,
                    status: .departed
                )
            ]
        )
    }
    
    @Test
    func executeWhenDispatchIsBoardingExecutesDeparture() async throws {
        let vehicleId = UUID()

        let dispatch = makeDispatch(
            vehicleId: vehicleId,
            status: .boarding
        )

        let exitResult = makeVehicleExitResult(
            vehicleId: vehicleId
        )

        let dispatchRepository = makeRepositories(
            dispatches: [dispatch]
        )

        let vehicleExit = FakeExecuteDispatchVehicleExitUseCase(
            result: exitResult
        )

        let sut = makeSUT(
            dispatchRepository: dispatchRepository,
            registerVehicleExit: vehicleExit
        )

        let result = try await sut.execute(
            dispatchId: dispatch.id
        )

        #expect(result.status == .departed)
        #expect(result.actualDeparture == exitResult.timestamp)
        #expect(
            dispatchRepository.updatedDispatches.first?.status == .departed
        )
    }

    @Test
    func executeWhenDispatchIsDelayedExecutesDeparture() async throws {
        let vehicleId = UUID()

        let dispatch = makeDispatch(
            vehicleId: vehicleId,
            status: .delayed
        )

        let exitResult = makeVehicleExitResult(
            vehicleId: vehicleId
        )

        let dispatchRepository = makeRepositories(
            dispatches: [dispatch]
        )

        let vehicleExit = FakeExecuteDispatchVehicleExitUseCase(
            result: exitResult
        )

        let sut = makeSUT(
            dispatchRepository: dispatchRepository,
            registerVehicleExit: vehicleExit
        )

        let result = try await sut.execute(
            dispatchId: dispatch.id
        )

        #expect(result.status == .departed)
        #expect(result.actualDeparture == exitResult.timestamp)
        #expect(
            dispatchRepository.updatedDispatches.first?.status == .departed
        )
    }

    @Test
    func executeWhenVehicleExitFailsDoesNotUpdateDispatch() async throws {
        let vehicleId = UUID()

        let dispatch = makeDispatch(
            vehicleId: vehicleId,
            status: .scheduled
        )

        let dispatchRepository = makeRepositories(
            dispatches: [dispatch]
        )

        let vehicleExit = FakeExecuteDispatchVehicleExitUseCase(
            error: .vehicleNotInsideTerminal
        )

        let sut = makeSUT(
            dispatchRepository: dispatchRepository,
            registerVehicleExit: vehicleExit
        )

        await expectTerminalError(.vehicleNotInsideTerminal) {
            _ = try await sut.execute(
                dispatchId: dispatch.id
            )
        }

        #expect(vehicleExit.executedVehicleIds.count == 1)
        #expect(dispatchRepository.updatedDispatches.isEmpty)
    }
}

private extension ExecuteDispatchUseCaseTests {

    func makeSUT(
        dispatches: [Dispatch] = []
    ) -> ExecuteDispatchUseCase {

        let dispatchRepository = makeRepositories(
            dispatches: dispatches
        )

        return makeSUT(
            dispatchRepository: dispatchRepository
        )
    }

    func makeSUT(
        dispatchRepository: DispatchRepository,
        registerVehicleExit: RegisterVehicleExitUseCase? = nil
    ) -> ExecuteDispatchUseCase {

        ExecuteDispatch(
            dispatchRepository: dispatchRepository,
            registerVehicleExit: registerVehicleExit
                ?? FakeExecuteDispatchVehicleExitUseCase()
        )
    }

    func makeRepositories(
        dispatches: [Dispatch] = []
    ) -> FakeExecuteDispatchDispatchRepository {

        FakeExecuteDispatchDispatchRepository(
            dispatches: dispatches
        )
    }

    func makeDispatch(
        id: UUID = UUID(),
        vehicleId: UUID = UUID(),
        routeId: UUID = UUID(),
        bayId: UUID = UUID(),
        scheduledDeparture: Date = Date(),
        actualDeparture: Date? = nil,
        status: DispatchStatus = .scheduled
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

    func makeVehicleExitResult(
        vehicleId: UUID = UUID(),
        plate: String = "ABC123",
        timestamp: Date = Date()
    ) -> VehicleExitResult {

        VehicleExitResult(
            vehicleId: vehicleId,
            plate: plate,
            timestamp: timestamp
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

private final class FakeExecuteDispatchDispatchRepository: DispatchRepository {

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
            dispatch.status != .cancelled &&
            dispatch.status != .departed
        }
    }

    func update(_ dispatch: Dispatch) async throws {
        updatedDispatches.append(dispatch)

        guard let index = dispatches.firstIndex(
            where: { $0.id == dispatch.id }
        ) else {
            return
        }

        dispatches[index] = dispatch
    }
}

private final class FakeExecuteDispatchVehicleExitUseCase:
    RegisterVehicleExitUseCase {

    private let result: VehicleExitResult?
    private let error: TerminalError?

    private(set) var executedVehicleIds: [UUID] = []

    init(
        result: VehicleExitResult? = nil,
        error: TerminalError? = nil
    ) {
        self.result = result
        self.error = error
    }

    func execute(
        vehicleId: UUID
    ) async throws -> VehicleExitResult {

        executedVehicleIds.append(vehicleId)

        if let error {
            throw error
        }

        guard let result else {
            fatalError(
                "FakeExecuteDispatchVehicleExitUseCase requires a result or error"
            )
        }

        return result
    }
}

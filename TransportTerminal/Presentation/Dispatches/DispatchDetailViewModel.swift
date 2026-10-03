//
//  DispatchDetailViewModel.swift
//  TransportTerminal
//
//  Created by Codex on 3/10/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class DispatchDetailViewModel {

    private let cancelDispatchUseCase: CancelDispatchUseCase
    private let executeDispatchUseCase: ExecuteDispatchUseCase

    let dispatch: DispatchDetailsResult

    private(set) var isExecuting = false
    private(set) var isCancelling = false
    private(set) var errorMessage: String?

    var canExecute: Bool {
        !isExecuting && !isCancelling && dispatch.status != .departed
    }

    var canCancel: Bool {
        !isExecuting && !isCancelling && dispatch.status != .cancelled &&
        dispatch.status != .departed
    }

    init(
        dispatch: DispatchDetailsResult,
        cancelDispatchUseCase: CancelDispatchUseCase,
        executeDispatchUseCase: ExecuteDispatchUseCase
    ) {
        self.dispatch = dispatch
        self.cancelDispatchUseCase = cancelDispatchUseCase
        self.executeDispatchUseCase = executeDispatchUseCase
    }

    func executeDispatch() async -> ExecuteDispatchResult? {
        isExecuting = true
        errorMessage = nil

        defer {
            isExecuting = false
        }

        do {
            return try await executeDispatchUseCase.execute(
                dispatchId: dispatch.id
            )
        } catch let error as TerminalError {
            errorMessage = message(for: error, action: .execute)
            return nil
        } catch {
            errorMessage = "Unable to execute dispatch."
            return nil
        }
    }

    func cancelDispatch() async -> CancelDispatchResult? {
        isCancelling = true
        errorMessage = nil

        defer {
            isCancelling = false
        }

        do {
            return try await cancelDispatchUseCase.execute(
                dispatchId: dispatch.id
            )
        } catch let error as TerminalError {
            errorMessage = message(for: error, action: .cancel)
            return nil
        } catch {
            errorMessage = "Unable to cancel dispatch."
            return nil
        }
    }
}

private extension DispatchDetailViewModel {

    enum DispatchAction {
        case execute
        case cancel
    }

    func message(
        for error: TerminalError,
        action: DispatchAction
    ) -> String {

        switch error {
        case .dispatchNotFound:
            return "Dispatch was not found."

        case .dispatchAlreadyCancelled:
            return "Dispatch is already cancelled."

        case .dispatchAlreadyDeparted:
            return "Dispatch has already departed."

        case .vehicleNotFound:
            return "Vehicle was not found."

        case .vehicleInMaintenance:
            return "Vehicle is currently in maintenance."

        case .vehicleNotInsideTerminal:
            return "Vehicle is not inside the terminal."

        case .companyNotFound,
             .companyInactive,
             .vehicleAlreadyInside,
             .routeNotFound,
             .routeInactive,
             .bayNotFound,
             .bayInactive,
             .vehicleAlreadyHasActiveDispatch,
             .bayAlreadyHasActiveDispatch:
            switch action {
            case .execute:
                return "Unable to execute dispatch."

            case .cancel:
                return "Unable to cancel dispatch."
            }
        }
    }
}

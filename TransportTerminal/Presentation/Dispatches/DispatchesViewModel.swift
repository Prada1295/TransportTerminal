//
//  DispatchesViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 15/09/26.
//
import Foundation
import Observation

@MainActor
@Observable
final class DispatchesViewModel {

    private let getActiveDispatchesUseCase: GetActiveDispatchesUseCase
    private let cancelDispatchUseCase: CancelDispatchUseCase
    private let executeDispatchUseCase: ExecuteDispatchUseCase

    private(set) var dispatches: [Dispatch] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        getActiveDispatchesUseCase: GetActiveDispatchesUseCase,
        cancelDispatchUseCase: CancelDispatchUseCase,
        executeDispatchUseCase: ExecuteDispatchUseCase
    ) {
        self.getActiveDispatchesUseCase = getActiveDispatchesUseCase
        self.cancelDispatchUseCase = cancelDispatchUseCase
        self.executeDispatchUseCase = executeDispatchUseCase
    }

    func loadDispatches() async {

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            dispatches = try await getActiveDispatchesUseCase.execute()
        } catch {
            dispatches = []
            errorMessage = "Unable to load dispatch information."
        }
    }

    func cancelDispatch(_ dispatch: Dispatch) async {

        errorMessage = nil

        do {
            _ = try await cancelDispatchUseCase.execute(
                dispatchId: dispatch.id
            )

            await loadDispatches()

        } catch {
            errorMessage = "Unable to cancel dispatch."
        }
    }

    func executeDispatch(_ dispatch: Dispatch) async {

        errorMessage = nil

        do {
            _ = try await executeDispatchUseCase.execute(
                dispatchId: dispatch.id
            )

            await loadDispatches()

        } catch {
            errorMessage = "Unable to execute dispatch."
        }
    }
}

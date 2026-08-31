//
//  HomeViewModel.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let getVehiclesInsideTerminalUseCase: GetVehiclesInsideTerminalUseCase

    private(set) var vehiclesInsideTerminal: [Vehicle] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(getVehiclesInsideTerminalUseCase: GetVehiclesInsideTerminalUseCase) {
        self.getVehiclesInsideTerminalUseCase = getVehiclesInsideTerminalUseCase
    }

    func loadVehiclesInsideTerminal() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            vehiclesInsideTerminal = try await getVehiclesInsideTerminalUseCase.execute()
        } catch {
            vehiclesInsideTerminal = []
            errorMessage = "Unable to load vehicles inside terminal."
        }
    }
}

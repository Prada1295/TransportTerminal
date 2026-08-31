//
//  TransportTerminalApp.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//

import SwiftUI

@main
struct TransportTerminalApp: App {
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            DashboardView(
                container: container
            )
        }
    }
}

//
//  HomeView.swift
//  TransportTerminal
//
//  Created by Andres Felipe Prada Chivata on 31/08/26.
//

import SwiftUI

struct HomeView: View {

    private let container: DependencyContainer

    @State private var viewModel: HomeViewModel
    @State private var selectedVehicle: Vehicle?

    init(container: DependencyContainer) {
        self.container = container

        _viewModel = State(
            initialValue: container.makeHomeViewModel()
        )
    }

    var body: some View {

        NavigationStack {

            List {

                Section("Vehicles inside terminal") {

                    if viewModel.isLoading {

                        ProgressView()

                    } else if let errorMessage = viewModel.errorMessage {

                        ContentUnavailableView(
                            "Could not load vehicles",
                            systemImage: "exclamationmark.triangle",
                            description: Text(errorMessage)
                        )

                    } else if viewModel.vehiclesInsideTerminal.isEmpty {

                        ContentUnavailableView(
                            "No vehicles inside",
                            systemImage: "bus",
                            description: Text(
                                "Registered entries will appear here."
                            )
                        )

                    } else {

                        ForEach(viewModel.vehiclesInsideTerminal) { vehicle in

                            Button {
                                selectedVehicle = vehicle
                            } label: {
                                VehicleInsideTerminalRow(
                                    vehicle: vehicle
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Transport Terminal")
            .refreshable {
                await viewModel.loadVehiclesInsideTerminal()
            }
            .task {
                await viewModel.loadVehiclesInsideTerminal()
            }
        }
        .fullScreenCover(item: $selectedVehicle) { vehicle in

            VehicleDetailView(
                vehicleId: vehicle.id,
                viewModel: container.makeVehicleDetailViewModel()
            )
        }
    }
}

private struct VehicleInsideTerminalRow: View {

    let vehicle: Vehicle

    var body: some View {

        HStack(spacing: 12) {

            Image(systemName: vehicle.type.systemImageName)
                .frame(width: 28)
                .foregroundStyle(.tint)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(vehicle.plate)
                    .font(.headline)

                Text(
                    "Capacity: \(vehicle.capacity) passengers"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(vehicle.status.displayName)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    .green.opacity(0.15),
                    in: Capsule()
                )
                .foregroundStyle(.green)
        }
        .padding(.vertical, 4)
    }
}

private extension VehicleType {

    var systemImageName: String {

        switch self {

        case .bus, .buseta, .microbus:
            "bus"

        case .van:
            "car"

        case .taxi:
            "taxi"
        }
    }
}

private extension VehicleStatus {

    var displayName: String {

        switch self {

        case .outsideTerminal:
            "Outside"

        case .insideTerminal:
            "Inside"

        case .dispatched:
            "Dispatched"

        case .maintenance:
            "Maintenance"
        }
    }
}

#Preview {
    HomeView(
        container: DependencyContainer()
    )
}
